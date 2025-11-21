# Backend Connectivity Troubleshooting

If your frontend cannot connect to the backend, follow these steps to diagnose the issue.

## 1. Check Container Status
Run this on your EC2 instance:
```bash
cd ~/bitwise/deploy/aws
docker compose ps
```
- **Expected**: Both `bitwise_backend` and `bitwise_frontend` should be `Up`.
- **If `Exit` or `Restarting`**: The container is crashing. Check logs (Step 2).

## 2. Check Backend Logs
See if the backend started successfully and is listening.
```bash
docker compose logs backend --tail=50
```
- **Look for**: `Listening on 0.0.0.0:3000` or `Nest application successfully started`.
- **If you see errors**: Fix the error (often database connection or missing env vars).

## 3. Test Local Connectivity (On the Server)
Check if the backend is responding locally on the server.
```bash
curl -v http://localhost:3000/api
```
- **Success**: You get a JSON response or a 404 (which means the server is reachable).
- **Failure**: `Connection refused` means the container isn't listening or port mapping is wrong.

## 4. Test Public Connectivity (Crucial for Frontend)
Since your frontend runs in the user's browser, the user's browser must be able to reach port 3000 directly.

**Run this from your LOCAL computer (not the server):**
```bash
curl -v http://47.129.118.12:3000/api
```
- **Success**: The backend is accessible to the world.
- **Failure (Timeout)**: **AWS Security Group Issue**. You need to open Port 3000 in AWS.
- **Failure (Connection Refused)**: The server is reachable, but nothing is listening on port 3000 (check Step 1 & 2).

# ...existing code...
## 5. Check AWS Security Groups (Most Common Cause)
If Step 3 works but Step 4 fails (Timeout), your AWS Firewall is blocking port 3000.

**This is the #1 reason for "Frontend works but Backend doesn't load".**

1.  Go to AWS Console -> EC2 -> Instances.
2.  Click your instance -> **Security** tab.
3.  Click the **Security Group** link (e.g., `sg-012345...`).
4.  Click **Edit Inbound Rules**.
5.  **Add Rule**:
    -   **Type**: Custom TCP
    -   **Port Range**: `3000`
    -   **Source**: `0.0.0.0/0` (Anywhere)
6.  Click **Save rules**.

Now try accessing `http://47.129.118.12:3000/api` again. It should work immediately.

    -   **Source**: `0.0.0.0/0` (Anywhere)
6.  Save rules.

## 6. Browser Console
Open your deployed website, press `F12` (Developer Tools), and go to the **Network** tab.
-   Refresh the page.
-   Look for red failed requests to `:3000`.
-   **`ERR_CONNECTION_TIMED_OUT`**: Firewall/Security Group issue.
-   **`ERR_CONNECTION_REFUSED`**: Backend is down.
-   **`CORS Error`**: Backend is up, but `CORS_ALLOWED_ORIGINS` in `.env` is wrong.
