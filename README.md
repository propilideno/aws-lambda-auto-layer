# aws-lambda-auto-layer
Script to create automatically lambda layers in AWS

## Requirements
- pip
- zip
- aws-cli (if you want to deploy)

## Example of usage

### Input
Define your desired python libraries
```bash
# Define the list of Python libraries
LIBRARIES=(
	"azure-storage-blob"
	"pandas pyarrow fastparquet" # Separate libraries by space
)
```
run `./create.sh`
### Output
```
/lib
    /azure-storage-blob
    /pandas_pyarrow_fastparquet
    azure-storage-blob.zip
    pandas_pyarrow_fastparquet.zip
create.sh
```
