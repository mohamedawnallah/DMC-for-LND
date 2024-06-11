#!/bin/bash

# Directory where generated client code will be stored.
CLIENT_LNRPC="lnrpc"

# Temporary directory for cloning Google APIs.
GOOGLE_APIS_DIR="/tmp/googleapis"

# Temporary files for lightning.proto and router.proto.
LIGHTNING_PROTO_FILE="/tmp/lightning.proto"
ROUTER_PROTO_FILE="/tmp/router.proto"

# Create the CLIENT_LNRPC directory if it doesn't exist.
if [ ! -d "$CLIENT_LNRPC" ]; then
  mkdir "$CLIENT_LNRPC"
fi

# Create a Python virtual environment named .ecrpc_client.
echo "Creating Python virtual environment .ecrpc_client"
python -m venv .ecrpc_client

# Activate the Python virtual environment.
echo "Activating Python virtual environment"
source .ecrpc_client/bin/activate

# Install the required Python packages.
echo "Installing required Python packages"
python -m pip install -r requirements.txt

# Clone the Google APIs repository into the temporary directory.
echo "Cloning Google APIs repository"
git clone https://github.com/googleapis/googleapis.git "$GOOGLE_APIS_DIR"

# Download the lightning.proto file into the temporary directory.
echo "Downloading lightning.proto"
curl -o "$LIGHTNING_PROTO_FILE" -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/lightning.proto

# Generate the gRPC client code for lightning.proto.
echo "Generating gRPC client code for lightning.proto"
python -m grpc_tools.protoc --proto_path="$GOOGLE_APIS_DIR":"/tmp" --python_out="$CLIENT_LNRPC" --grpc_python_out="$CLIENT_LNRPC" "$LIGHTNING_PROTO_FILE"

# Download the router.proto file into the temporary directory.
echo "Downloading router.proto"
curl -o "$ROUTER_PROTO_FILE" -s https://raw.githubusercontent.com/lightningnetwork/lnd/master/lnrpc/routerrpc/router.proto

# Generate the gRPC client code for router.proto.
echo "Generating gRPC client code for router.proto"
python -m grpc_tools.protoc --proto_path="$GOOGLE_APIS_DIR":"/tmp" --python_out="$CLIENT_LNRPC" --grpc_python_out="$CLIENT_LNRPC" "$ROUTER_PROTO_FILE"

# Clean up temporary files and directories.
echo "Cleaning up temporary files and directories"
rm -rf "$LIGHTNING_PROTO_FILE" "$ROUTER_PROTO_FILE" "$GOOGLE_APIS_DIR"
