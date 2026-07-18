#/bin/bash


mkdir -p kubernetes/namespaces

for i in {1..12}; do
cat > kubernetes/namespaces/s${i}.yaml <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: s${i}
  labels:
    environment: training
    cluster: pmwi
    student: s${i}
EOF
done
