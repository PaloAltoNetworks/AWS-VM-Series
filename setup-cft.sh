
S3_BUCKET_NAME="panw-aws-resources-$(uuidgen)"
S3_FOLDER_NAME="panw-vmseries-gwlb/"

echo "Creating new S3 bucket ${S3_BUCKET_NAME} for sourcing the CFTs"
aws s3 mb s3://${S3_BUCKET_NAME}

echo "Creating new folder ${S3_FOLDER_NAME} in the S3 bucket"
aws s3api put-object --bucket ${S3_BUCKET_NAME} --key ${S3_FOLDER_NAME} --content-length 0

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR

echo "Updating the CFTs with the new S3 bucket name."
sed -i "s/__source_s3_bucket_name__/${S3_BUCKET_NAME}/g" ./vmseries-gwlb-2023/cloud-formation-templates/aws-panw-gwlb-cfn-root.yaml
sed -i "s/__source_s3_bucket_name__/${S3_BUCKET_NAME}/g" ./vmseries-gwlb-2023/cloud-formation-templates/aws-panw-gwlb-cfn-security.yaml
sed -i "s/__source_s3_bucket_name__/${S3_BUCKET_NAME}/g" ./vmseries-gwlb-2023/cloud-formation-templates/aws-panw-gwlb-cfn-vmseries.yaml

echo "Starting upload of CFT and bootstrap files to S3 bucket"
aws s3 cp ./vmseries-gwlb-2023/s3-assets/bootstrap.xml s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}
aws s3 cp ./vmseries-gwlb-2023/s3-assets/init-cfg.txt s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}
aws s3 cp ./vmseries-gwlb-2023/s3-assets/authcodes s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME}
aws s3 cp ./vmseries-gwlb-2023/cloud-formation-templates s3://${S3_BUCKET_NAME}/${S3_FOLDER_NAME} --recursive

echo "Setup completed successfully. Please proceed to CFT deployment."
echo "Please use the below Template URL for CFT deployment."
echo "TEMPLATE_URL = https://${S3_BUCKET_NAME}.s3.${AWS_REGION}.amazonaws.com/${S3_FOLDER_NAME}aws-panw-gwlb-cfn-root.yaml"
