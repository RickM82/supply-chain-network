get_pods() {
  #1 - app name
  kubectl get pods -l app=$1 --field-selector status.phase=Running -n supply-chain-network --template '{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | head -n 1
}

# Exit on errors
set -e

export CC_PACKAGE_ID=supplyChain_1:31787638b021a390fa4c8e363b58b80765cc1247ebb706fcb14796f513e398bb
# Use CLI shell to create channel

echo "Approve chaincode on RegulatoryDepartment"
kubectl exec -n supply-chain-network $(get_pods "cli-regulatory-department") -- /bin/bash -c "/tmp/hyperledger/scripts/approveChaincodeDefinition.sh "$CC_PACKAGE_ID

echo "Approve chaincode on Producer"
kubectl exec -n supply-chain-network $(get_pods "cli-producer") -- /bin/bash -c "/tmp/hyperledger/scripts/approveChaincodeDefinition.sh "$CC_PACKAGE_ID

echo "Approve chaincode on Manufacturer"
kubectl exec -n supply-chain-network $(get_pods "cli-manufacturer") -- /bin/bash -c "/tmp/hyperledger/scripts/approveChaincodeDefinition.sh "$CC_PACKAGE_ID

echo "Approve chaincode on Deliverer"
kubectl exec -n supply-chain-network $(get_pods "cli-deliverer") -- /bin/bash -c "/tmp/hyperledger/scripts/approveChaincodeDefinition.sh "$CC_PACKAGE_ID

echo "Approve chaincode on Retailer"
kubectl exec -n supply-chain-network $(get_pods "cli-retailer") -- /bin/bash -c "/tmp/hyperledger/scripts/approveChaincodeDefinition.sh "$CC_PACKAGE_ID

echo "Check Commit Readiness for channel chaincode"
kubectl exec -n supply-chain-network $(get_pods "cli-regulatory-department") -- /bin/bash -c "/tmp/hyperledger/scripts/checkCommitReadiness.sh"

echo "Commit chaincode"
kubectl exec -n supply-chain-network $(get_pods "cli-regulatory-department") -- /bin/bash -c "/tmp/hyperledger/scripts/commitChaincode.sh"

echo "Invoke chaincode"
kubectl exec -n supply-chain-network $(get_pods "cli-regulatory-department") -- /bin/bash -c "/tmp/hyperledger/scripts/invokeChaincode.sh"
