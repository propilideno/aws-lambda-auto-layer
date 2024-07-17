#!/bin/bash

# Define the list of Python libraries
LIBRARIES=(
	"azure-storage-blob"
	"pandas pyarrow fastparquet"
)

# Function to build and deploy Lambda layers
ROOT_PATH=$(pwd)
build_layers() {
    # Loop through each library
    for LIBRARY in "${LIBRARIES[@]}"; do
        echo "Building layer for $LIBRARY..."

		# Translate spaces to underscore
		LIBRARY_NORMALIZED_NAME=$(echo $LIBRARY | tr " " "_" )

        # Create directory for the library
        mkdir -p lib/$LIBRARY_NORMALIZED_NAME/python

        # Install the library into its directory
		pip install -t lib/$LIBRARY_NORMALIZED_NAME/python $LIBRARY

        # Zip the library directory
        bash -c "cd lib/$LIBRARY_NORMALIZED_NAME && zip -r $ROOT_PATH/lib/$LIBRARY_NORMALIZED_NAME.zip python"
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

build_layers
deploy_layers
