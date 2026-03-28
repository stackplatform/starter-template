# Haxe Stack Platform Starter Template

This repository is a clean, minimal "Project Starter" for building full-stack Haxe applications on **Stack Platform**. It demonstrates how to use the **SideWinder** web server and **HaxeUI** to create a secure integration with the Stack Platform SaaS.

## Architecture 

The template follows a 3-tier architecture designed for security and scalability:

1.  **HaxeUI Client**: A cross-platform UI (HashLink/HTML5) that provides the frontend experience. It communicates with the *local* integration server.
2.  **Local Integration Server**: A SideWinder-based Haxe server that acts as a secure proxy. It handles authentication and protects your Stack Platform `API_KEY` by making SaaS calls on behalf of the client.
3.  **Stack Platform SaaS**: The external hosted platform that provides the real backend services.

## Prerequisites

*   **Haxe 4.x**: The foundation for both client and server.
*   **Haxe Maintenance Manager (HMM)**: Used to manage project-specific library versions.
    *   `haxelib install hmm`
    *   `haxelib run hmm setup`
*   **Haxe Libraries**:
    From the root or sub-project directories, run:
    ```bash
    haxelib run hmm install
    ```
    This will install all required libraries including **SideWinder**, **HaxeUI**, **OpenFL**, and the **Stack Platform SDK**.

## Getting Started

### 1. Configure the Environment
Copy the example configuration to a new `.env` file in the `config/` directory:

```bash
cp config/.env.example config/.env
```

Open `config/.env` and enter your **Stack Platform Project API Key** found in your project settings dashboard.

### 2. Run the Local Server
Navigate to the `server/` directory and build/run the HL (HashLink) target:

```bash
cd server
haxelib run hmm install
haxe server.hxml
hl server.hl
```

The server will start on `http://localhost:8081`.

### 3. Run the Client
Navigate to the `client/` directory and run the Lime test command:

```bash
cd client
haxelib run hmm install
lime test hl
```

The client will open and automatically fetch the project status from your local server.

## Key Features Demonstrated

*   **Shared Contracts**: See `shared/app/services/IProjectIntegrationService.hx` for how to define API contracts once and use them in both client and server.
*   **AutoRouter**: The server uses SideWinder's `AutoRouter` to automatically map interface methods to HTTP endpoints.
*   **AutoClientAsync**: The client uses `AutoClientAsync` to generate a type-safe API client from the shared interface.
*   **Dependency Injection**: Decoupled service implementations using `hx-injection`.
*   **Secret Management**: Pattern for keeping your API Key secure by never exposing it to the client side.

## Security Warning

> [!CAUTION]
> Never hardcode your Stack Platform API Key in your source code. The local server implementation shows how to load it from an environment variable and use it only in server-side calls.

## How to Customize

1.  **Add a new DTO**: Update `shared/app/models/ProjectModels.hx`.
2.  **Add a new method**: Update `shared/app/services/IProjectIntegrationService.hx`.
3.  **Implement the logic**: Update `server/Source/app/services/ProjectIntegrationService.hx`.
4.  **Update the UI**: Modify `client/Assets/dashboard.xml` and handle the new data in `client/Source/app/views/DashboardView.hx`.

---

© 2026 Stack Platform. This template is intended as an example for developers. Use it as a starting point for your own projects!
