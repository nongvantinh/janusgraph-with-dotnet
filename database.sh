#!/usr/bin/env bash

set -euo pipefail

dns_names=(
    "mydatabase.com"
    "janusgraph.mydatabase.com"
    "cassandra.mydatabase.com"
    "elasticsearch.mydatabase.com"
)

setup_nginx_ingress() {
    echo "Setting up NGINX Ingress..."
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml

    echo "Waiting for the Ingress Controller deployment to be available..."
    kubectl wait --namespace ingress-nginx --for=condition=available deployment/ingress-nginx-controller --timeout=10s
    echo -n "Waiting for the Ingress Controller pod to be Ready..."
    while true; do
        status=$(kubectl get pods -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx | awk '$1 ~ /ingress-nginx-controller/ && $2 == "1/1" {print $2}')
        
        if [ "$status" == "1/1" ]; then
            echo -e "\rSuccess: Ingress Controller is Running."
            break
        else
            sleep 0.5
        fi
    done

    create_pod=$(kubectl get pods -n ingress-nginx -o name | grep ingress-nginx-admission-create)
    patch_pod=$(kubectl get pods -n ingress-nginx -o name | grep ingress-nginx-admission-patch)

    for pod in "$create_pod" "$patch_pod"; do
        kubectl wait --namespace ingress-nginx --for=jsonpath='{.status.phase}'=Succeeded "$pod" --timeout=10s || true
        pod_status=$(kubectl get "$pod" -n ingress-nginx -o jsonpath='{.status.phase}')
        if [[ "$pod_status" == "Succeeded" ]]; then
            echo "$pod has completed successfully."
        else
            echo "$pod did not complete successfully."
        fi
    done

    echo "Success: Ingress Controller is Running and admission pods are completed."
}

update_host() {
    echo "Fetching IP address for Ingress..."
    while true; do
        ip_address=$(kubectl get ing -o jsonpath='{.items[*].status.loadBalancer.ingress[*].ip}' 2>/dev/null)

        if [ -n "$ip_address" ]; then
            echo -e "Found IP address: $ip_address"
            break
        else
            echo -e "\rWaiting for IP address to be available..."
            sleep 0.5
        fi
    done

    # Append new entries to /etc/hosts
    for dns_name in "${dns_names[@]}"; do
        if ! grep -q "$dns_name" /etc/hosts; then
            echo "$ip_address $dns_name" | sudo tee -a /etc/hosts > /dev/null
            echo "Added $ip_address $dns_name to /etc/hosts"
        else
            echo "$dns_name already exists in /etc/hosts, skipping."
        fi
    done
}

setup() {
    setup_nginx_ingress
    echo "Applying janusgraph-cassandra-elasticsearch configuration..."
    kubectl apply -f janusgraph-cassandra-elasticsearch.yaml
}

cleanup() {
    echo "Cleaning up resources..."
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.9.4/deploy/static/provider/cloud/deploy.yaml || true
    kubectl delete -f janusgraph-cassandra-elasticsearch.yaml || true


    for dns_name in "${dns_names[@]}"; do
        if sudo sed -i.bak "/ $dns_name/d" /etc/hosts; then
            echo "Removed old entry for $dns_name from /etc/hosts"
        else
            echo "No entry found for $dns_name in /etc/hosts"
        fi
    done
}

main() {
    if [[ "$#" -eq 0 ]]; then
        echo "No options provided. Use --setup, --cleanup, or --update-host."
        exit 1
    fi

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --setup)
                setup
                shift
                ;;
            --cleanup)
                cleanup
                shift
                ;;
            --update-host)
                update_host
                shift
                ;;
            *)
                echo "Invalid option: $1"
                exit 1
                ;;
        esac
    done
}

main "$@"
