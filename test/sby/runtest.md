# Formal Verification Test Instructions

This document provides instructions for running formal verification tests using SymbiYosys (sby).

## Prerequisites

- Docker must be installed on your system
- IIC-OSIC-TOOLS Docker container must be available

## Setup Instructions

### 1. Start Docker Service

First, ensure the Docker service is running on your system:

```bash
systemctl start docker
```

### 2. Verify Docker Status

Check that Docker is running properly:

```bash
systemctl status docker
```

You should see an active (running) status.

### 3. Launch the OSIC Tools Container

Start the Docker container with the verification tools:

```bash
/IIC-OSIC-TOOLS/start_x.sh
```

A new terminal window will appear with the container environment ready. Continue inside the new terminal.

## Running Tests

### Testing out_stage Module

To perform formal verification on the `out_stage.v` module:

1. Navigate to the test directory:
   ```bash
   cd test/sby/
   ```

2. Run the formal verification:
   ```bash
   sby -f out_stage.sby
   ```

The `-f` flag forces a fresh run, removing any previous verification results.

Results will be saved in the `out_stage/` sub directory.

### Testing in_stage Module

To perform formal verification on the `in_stage.v` module:

1. Navigate to the test directory:
   ```bash
   cd test/sby/
   ```

2. Run the formal verification:
   ```bash
   sby -f in_stage.sby
   ```

Results will be saved in the `in_stage/` sub directory.


