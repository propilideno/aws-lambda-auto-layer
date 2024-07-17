#!/bin/bash

# Define the list of Python libraries
LIBRARIES=(
    "pandas"
	"azure-storage-blob"
)

# Function to build and deploy Lambda layers
ROOT_PATH=$(pwd)
build_layers() {
    # Loop through each library
    for LIBRARY in "${LIBRARIES[@]}"; do
        echo "Building layer for $LIBRARY..."

        # Create directory for the library
        mkdir -p lib/$LIBRARY/python

        # Install the library into its directory
        pip install $LIBRARY -t lib/$LIBRARY/python

        # Zip the library directory
        bash -c "cd lib/$LIBRARY && zip -r $ROOT_PATH/lib/$LIBRARY.zip python"
    done
    echo "All Lambda Layers deployed successfully."
}

deploy_layers(){
    # Deploy each zip file to AWS Lambda
    for ZIP_FILE in lib/*.zip; do
        # Extract the library name from the zip file path
        LIBRARY_NAME=$(basename "$ZIP_FILE" .zip)
        echo "Deploying $LIBRARY_NAME to AWS Lambda..."

        # Replace these variables with your AWS settings
        DESCRIPTION="Built with $(python --version)"

        # Upload the layer to AWS Lambda
		aws lambda publish-layer-version \
			--layer-name $LIBRARY_NAME \
			--description "$DESCRIPTION" \
			--zip-file fileb://$ZIP_FILE \
			--compatible-runtimes python3.12 \
			--compatible-architectures $(uname --machine)
        echo "Deployment of $LIBRARY_NAME completed."
    done
}

#build_layers
deploy_layers
