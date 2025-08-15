
#!/bin/bash

# Blue-Green Traffic Switching Script
# Usage: ./switch-traffic.sh [blue|green|status]

set -e

NAMESPACE="default"
SERVICE_NAME="nginx-service"

show_status() {
    echo "🔍 Current Traffic Status:"
    echo "========================"

    CURRENT_VERSION=$(kubectl get service $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.spec.selector.version}')
    echo "Current active version: $CURRENT_VERSION"

    echo ""
    echo "📊 Pod Status:"
    kubectl get pods -l app=nginx -n $NAMESPACE

    echo ""
    echo "🌐 Service Endpoints:"
    kubectl get endpoints -l app=nginx -n $NAMESPACE
}

switch_to_blue() {
    echo "🔵 Switching traffic to Blue environment..."

    kubectl patch service $SERVICE_NAME -n $NAMESPACE -p '{"spec":{"selector":{"version":"blue"}}}'

    echo "✅ Traffic switched to Blue environment"
    show_status
}

switch_to_green() {
    echo "🟢 Switching traffic to Green environment..."

    kubectl patch service $SERVICE_NAME -n $NAMESPACE -p '{"spec":{"selector":{"version":"green"}}}'

    echo "✅ Traffic switched to Green environment"  
    show_status
}

health_check() {
    local version=$1
    echo "🏥 Performing health check for $version environment..."

    SERVICE_URL=$(minikube service nginx-${version}-service --url)

    if curl -f "$SERVICE_URL" >/dev/null 2>&1; then
        echo "✅ $version environment is healthy"
        return 0
    else
        echo "❌ $version environment is not responding"
        return 1
    fi
}

# Main execution
case "$1" in
    "blue")
        if health_check "blue"; then
            switch_to_blue
        else
            echo "❌ Cannot switch to blue - health check failed"
            exit 1
        fi
        ;;
    "green")
        if health_check "green"; then
            switch_to_green
        else
            echo "❌ Cannot switch to green - health check failed"
            exit 1
        fi
        ;;
    "status")
        show_status
        ;;
    *)
        echo "Usage: $0 [blue|green|status]"
        echo ""
        echo "Commands:"
        echo "  blue   - Switch traffic to blue environment"
        echo "  green  - Switch traffic to green environment"  
        echo "  status - Show current traffic status"
        exit 1
        ;;
esac
