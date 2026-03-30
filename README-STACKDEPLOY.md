# StackDeploy Build & Deploy Examples

This directory contains example configurations and scripts to help you set up automated builds and deployments with Stack Platform.

## Quick Navigation

- **[stackdeploy.json](stackdeploy.json)** - Basic single-platform configuration
- **[stackdeploy-haxe-multiplatform.json](stackdeploy-haxe-multiplatform.json)** - Multi-platform Haxe app
- **[stackdeploy-with-scripts.json](stackdeploy-with-scripts.json)** - Using external build scripts
- **[scripts/](scripts/)** - Platform-specific build scripts

## Configuration Examples

### Simple Single-Platform Build

```json
{
  "projectId": "my-app",
  "version": "1.0.0",
  "builds": [{
    "name": "Linux x64",
    "platform": "linux",
    "arch": "x64",
    "command": "bash scripts/build-linux-x64.sh",
    "artifact": "dist/app-linux-x64.zip"
  }]
}
```

### Multi-Platform Build

See [stackdeploy-haxe-multiplatform.json](stackdeploy-haxe-multiplatform.json)

Defines builds for:
- Linux x64
- Windows x64
- macOS x64

Each with its own compile command and artifact path.

### Using External Scripts

See [stackdeploy-with-scripts.json](stackdeploy-with-scripts.json)

Delegates to helper scripts:
- `scripts/build-linux-x64.sh`
- `scripts/build-windows-x64.ps1` or `scripts/build-windows-x64.bat`
- `scripts/build-macos-x64.sh`

## Build Scripts

All in the `scripts/` directory:

### Universal Build Script

**Bash:**
```bash
bash scripts/build.sh              # Auto-detect platform
bash scripts/build.sh linux x64    # Explicit platform
```

**PowerShell:**
```powershell
powershell -File scripts/build.ps1              # Auto-detect platform
powershell -File scripts/build.ps1 -Platform windows -Arch x64
```

### Platform-Specific Scripts

**Bash versions:**
- `build-linux-x64.sh` - Build for Linux
- `build-macos-x64.sh` - Build for macOS

**Windows versions (choose one approach):**
- `build-windows-x64.bat` - Traditional batch script
- `build-windows-x64.ps1` - Modern PowerShell script

Each script:
1. Compiles your application (Haxe command)
2. Packages into a ZIP file
3. Verifies the ZIP is valid
4. Outputs to `dist/` directory

### Customizing Build Scripts

**Bash pattern:**
```bash
#!/bin/bash
set -e  # Exit on first error

echo "Building..."

# 1. Create/clean output directory
mkdir -p dist
rm -f dist/app-*.zip

# 2. Compile
haxe build-linux-x64.hxml

# 3. Package
zip -r dist/app-linux-x64.zip bin/

# 4. Verify
unzip -t dist/app-linux-x64.zip > /dev/null

echo "✓ Build complete!"
```

**PowerShell pattern:**
```powershell
$ErrorActionPreference = "Stop"

Write-Host "Building..."

# 1. Create/clean output directory
$buildDir = "dist"
if (-not (Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}
Remove-Item "dist/app-*.zip" -Force -ErrorAction SilentlyContinue

# 2. Compile
haxe build-windows-x64.hxml

# 3. Package
Compress-Archive -Path "bin" -DestinationPath "dist/app-windows-x64.zip" -Force

# 4. Verify
$shell = New-Object -ComObject Shell.Application
$zipItem = $shell.NameSpace("dist/app-windows-x64.zip")
if ($zipItem.Items().Count -eq 0) {
    throw "Zip file is empty or invalid"
}

Write-Host "✓ Build complete!"
```

Customize the compile and package steps for your needs.


## How to Use These Examples

### Step 1: Copy to Your Project

```bash
# Copy config
cp stackdeploy-haxe-multiplatform.json ../../../stackdeploy.json

# Copy scripts
cp -r scripts ../../../scripts/
```

### Step 2: Customize for Your Project

Edit `stackdeploy.json`:
- Change `projectId` to your Stack Platform project ID
- Update build commands (your actual Haxe compilation)
- Update artifact paths (where your build outputs to)

Edit build scripts:
- Adjust compilation commands
- Update output directory structure
- Add any preprocessing/postprocessing steps

### Step 3: Test Locally

**Bash (Linux/macOS):**
```bash
# Set your API key
export STACK_PROJECT_KEY=spk_proj_...

# Test the build script
bash scripts/build.sh

# Test the full push
haxelib run stackdeploy push --config stackdeploy.json
```

**PowerShell (Windows):**
```powershell
# Set your API key
$env:STACK_PROJECT_KEY = 'spk_proj_...'

# Test the build script
powershell -File scripts/build.ps1

# Test the full push
haxelib run stackdeploy push --config stackdeploy.json
```

### Step 4: Set Up GitHub Actions

```bash
# Copy workflow
cp ../github-actions/build-and-deploy-multi-platform.yml ../../.github/workflows/
```

Then add GitHub secret:
- Go to repository Settings
- Secrets and variables → Actions
- New secret: `STACK_PROJECT_KEY`

## Configuration Reference

### stackdeploy.json Fields

```json
{
  "projectId": "string",              // Project ID or "self"
  "version": "string|auto",           // Version or "auto" for git tag
  "description": "string",            // (Optional) Release description
  "metadata": {},                     // (Optional) Custom metadata
  "builds": [
    {
      "name": "string",               // Display name
      "platform": "linux|windows|macos",
      "arch": "x64|x86|arm64",
      "command": "string",            // (Optional) Build command
      "artifact": "string"            // Path to ZIP file
    }
  ]
}
```

### Environment Variables

```bash
# Required
STACK_PROJECT_KEY=spk_proj_...

# Optional
STACK_SERVER_URL=https://haxestack.com
```

## Workflow Descriptions

### Local Development

```
1. Run build script manually
   bash scripts/build.sh
   
2. Generates: dist/app-*.zip

3. Push to platform manually
   haxelib run stackdeploy push

4. Artifacts uploaded to Stack Platform
```

### GitHub Actions Automated

```
1. Push code to main branch

2. GitHub Actions triggers:
   - Creates release
   - Build jobs run in parallel:
     * Linux runner builds for Linux
     * Windows runner builds for Windows
     * macOS runner builds for macOS
   - Each uploads artifact automatically

3. Finalize job runs after all complete

4. Result: Multi-platform release deployed
```

## Supported Platforms

| Platform | Architecture | Build Runner | Notes |
|----------|--------------|--------------|-------|
| linux | x64 | ubuntu-latest | Most common |
| linux | x86 | ubuntu-latest | Legacy support |
| linux | arm64 | ubuntu-latest | ARM64 systems |
| windows | x64 | windows-latest | Native Windows |
| windows | x86 | windows-latest | Legacy 32-bit |
| macos | x64 | macos-latest | Intel Macs |
| macos | arm64 | macos-latest | Apple Silicon |

## Troubleshooting

### Build script fails locally

Check:
1. Haxe compilation works: `haxe build-linux-x64.hxml`
2. Output files exist: `ls -la bin/`
3. Zip command available: `which zip`
4. Artifact path correct in script

### "Build artifact not found"

Solutions:
1. Verify script ran completely: check exit code
2. Check artifact path is correct: `ls -la dist/`
3. Run build script manually: `bash scripts/build-linux-x64.sh`
4. Check relative vs absolute paths

### Push command fails

Check:
1. API key is set: `echo $STACK_PROJECT_KEY`
2. Project ID is correct in stackdeploy.json
3. Artifact files exist: `ls -la dist/`
4. Files are valid zips: `unzip -t dist/app-*.zip`

### GitHub Actions workflow doesn't trigger

Check:
1. Workflow file in `.github/workflows/`
2. File has correct name (ends in `.yml`)
3. YAML syntax is valid
4. Event trigger is correct (`on: push:` branch names)
5. Secret is added to repository

## Next Steps

- Read [StackDeploy CLI Guide](../../docs/STACKDEPLOY_CLI_GUIDE.md)
- Review [GitHub Actions Setup](../../docs/GITHUB_ACTIONS_SETUP.md)
- Check [Developer Guide](../../docs/STACKDEPLOY_DEVELOPER_GUIDE.md)
- Explore [API Documentation](../../STACKDEPLOY_IMPLEMENTATION.md)

## Different Project Types

### For a Node.js Project (Bash)

Modify stackdeploy.json:
```json
{
  "builds": [{
    "command": "npm run build && npm run package",
    "artifact": "dist/app-linux-x64.zip"
  }]
}
```

### For a Python Project (Bash)

```json
{
  "builds": [{
    "command": "python build.py && zip -r dist/app.zip .",
    "artifact": "dist/app.zip"
  }]
}
```

### For a .NET Project (PowerShell)

```json
{
  "builds": [{
    "platform": "windows",
    "command": "powershell -Command \"dotnet publish -c Release -o bin/publish; Compress-Archive -Path bin/publish -DestinationPath dist/app.zip -Force\"",
    "artifact": "dist/app.zip"
  }]
}
```

### For C++ (CMake) - Cross Platform

```json
{
  "builds": [
    {
      "platform": "linux",
      "command": "mkdir -p build && cd build && cmake .. && make && cd .. && zip -r dist/app-linux.zip bin/",
      "artifact": "dist/app-linux.zip"
    },
    {
      "platform": "windows",
      "command": "powershell -Command \"mkdir -Force build; cd build; cmake ..; cmake --build . --config Release; cd ..; Compress-Archive -Path bin -DestinationPath dist/app-windows.zip -Force\"",
      "artifact": "dist/app-windows.zip"
    }
  ]
}
```

### For Docker

```json
{
  "builds": [{
    "name": "Docker Image",
    "command": "docker build -t myapp:latest . && docker save myapp:latest | gzip > dist/image.tar.gz",
    "artifact": "dist/image.tar.gz"
  }]
}
```

## Tips & Best Practices

1. **Test scripts locally first** before committing to CI/CD
2. **Use absolute paths** in artifact specs if relative paths don't work
3. **Keep build outputs** in `dist/` directory (git-ignored)
4. **Version consistently** - use semantic versioning (v1.2.3)
5. **Add build verification** - test the ZIP is valid before upload
6. **Log progress** - helps debug issues in CI/CD
7. **Handle errors gracefully** - `set -e` in bash stops on first error

## Support

For issues:
1. Check this README
2. Review example files
3. Read [StackDeploy CLI Guide](../../docs/STACKDEPLOY_CLI_GUIDE.md)
4. Check [Troubleshooting](../../docs/STACKDEPLOY_CLI_GUIDE.md#troubleshooting)
5. Contact Stack Platform support
