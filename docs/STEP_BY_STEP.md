# Step-by-Step Guide (follow in order)

Total time: about 45-60 minutes. Do Parts 1-4 first, then the demo in Part 5.

---

## Part 1 - Install on your laptop (5 min)

You only need **Git**. Docker and Trivy on your laptop are optional (the pipeline runs them in the cloud).

| Tool | Download | Check it works |
|------|----------|----------------|
| Git | https://git-scm.com/downloads | `git --version` |
| VS Code (optional) | https://code.visualstudio.com | - |
| Docker Desktop (optional, for local tests) | https://www.docker.com/products/docker-desktop | `docker --version` |

Unzip `vuln-gate.zip` and open a terminal (Git Bash on Windows) inside the `vuln-gate` folder.

---

## Part 2 - Put the project on GitHub (10 min)

1. On github.com click **New repository**. Name it `vuln-gate`, keep it **Public** (simplest for free GHCR + Actions), do NOT add a README.
2. In the terminal inside the project folder:
   ```bash
   git init
   git add .
   git commit -m "Initial commit: container vulnerability gate"
   git branch -M main
   git remote add origin https://github.com/<YOUR_USERNAME>/vuln-gate.git
   git push -u origin main
   ```
   (GitHub will ask you to sign in; use a Personal Access Token if it asks for a password.)
3. Allow the pipeline to push images:
   **Repo -> Settings -> Actions -> General -> Workflow permissions -> Read and write permissions -> Save.**
4. Open the **Actions** tab. The first run starts automatically. It should be GREEN (BUILD_TARGET is the secure `Dockerfile`). The `deploy` job will show a warning until Part 4 is done - that is expected.

---

## Part 3 - Get a Linux server (15 min)

Pick ONE option:

**Option A - Azure for Students (recommended, no card needed)**
1. https://azure.microsoft.com/free/students -> sign in with your college email.
2. Create a resource -> **Virtual machine**: Ubuntu Server 22.04 LTS, size `B1s` or `B2s`.
3. Authentication: **SSH public key** (let Azure generate it and download the `.pem` file) - or paste your own key from Part 4.
4. Inbound ports: allow **SSH (22)** and **HTTP (80)**.
5. Create, then copy the VM's **public IP**.

**Option B - any VPS you already have** (DigitalOcean from the Student Pack, AWS, Oracle, etc.): Ubuntu with ports 22 and 80 open.

Then set it up:
```bash
ssh -i <your-key.pem> <username>@<SERVER_IP>        # first login
# copy scripts/setup-server.sh to the server, or paste its contents into a file, then:
bash setup-server.sh
exit                                                # log out, log in again
ssh -i <your-key.pem> <username>@<SERVER_IP>
docker run --rm hello-world                         # must print "Hello from Docker!"
```

> If the page won't open later, the #1 cause is port 80 blocked in the cloud portal's firewall / network security group.

---

## Part 4 - Connect GitHub to the server (10 min)

1. On your laptop make a dedicated deploy key:
   ```bash
   ssh-keygen -t ed25519 -f deploy_key -N ""
   ```
   This creates `deploy_key` (private) and `deploy_key.pub` (public). **Never commit these.**
2. Put the public key on the server:
   ```bash
   ssh -i <your-key.pem> <username>@<SERVER_IP> "echo '$(cat deploy_key.pub)' >> ~/.ssh/authorized_keys"
   ```
3. Test it: `ssh -i deploy_key <username>@<SERVER_IP> "docker ps"` - should print an empty table without errors.
4. In the repo: **Settings -> Secrets and variables -> Actions -> New repository secret**. Add three:

   | Name | Value |
   |------|-------|
   | `SERVER_HOST` | the server public IP |
   | `SERVER_USER` | SSH username (e.g. `azureuser` or `ubuntu`) |
   | `SERVER_SSH_KEY` | the full contents of the `deploy_key` file (including the BEGIN/END lines) |

5. Re-run the pipeline: **Actions -> latest run -> Re-run all jobs**. When green, open `http://<SERVER_IP>/` - you should see the page with `Image variant: secure`.

---

## Part 5 - The demo (do this twice before 2 PM)

**Failing scan:**
```bash
echo "Dockerfile.vulnerable" > BUILD_TARGET
git add BUILD_TARGET && git commit -m "demo: vulnerable image" && git push
```
Actions run: `scan` RED, `deploy` skipped. Open the failed step to show the CVE table. Download the `trivy-reports-*` artifact from the run page.

**Passing scan (updated image):**
```bash
echo "Dockerfile" > BUILD_TARGET
git add BUILD_TARGET && git commit -m "demo: patched image" && git push
```
`scan` GREEN, `deploy` GREEN, refresh `http://<SERVER_IP>/`.

---

## Part 6 - If something goes wrong

| Symptom | Fix |
|---------|-----|
| Secure image also fails the gate | Open the failed step, see which package/CVE. Change `python:3.12-alpine` to a newer tag in `Dockerfile`, or bump the package in `app/requirements.txt`. |
| Vulnerable image unexpectedly PASSES | Lower the bar: set `SEVERITY_THRESHOLD: "CRITICAL,HIGH,MEDIUM"` in the workflow, or use an older base such as `python:3.7`. |
| `denied: permission_denied` when pushing to GHCR | Part 2 step 3 (workflow permissions Read and write). |
| `ssh: handshake failed` in deploy | Wrong `SERVER_USER` / key. Re-test with the command in Part 4 step 3; make sure the whole private key (with BEGIN/END lines) is in the secret. |
| Deploy green but page won't load | Open inbound TCP 80 in the cloud portal firewall. |
| `pull access denied` on the server | The deploy script logs in with the job token; make sure the repo is on `main` and the push step succeeded. |
| Trivy "failed to download DB" / rate limit | Click **Re-run failed jobs** once. |
| Actions don't start | Check the file is at `.github/workflows/security-gate.yml` and the Actions tab isn't disabled. |

---

## Part 7 - Submission checklist (finish by 2:00 PM)

- [ ] Repo link
- [ ] Live URL `http://<SERVER_IP>/`
- [ ] Screenshot: failed run (red `scan`, skipped `deploy`) + CVE table
- [ ] Screenshot: passing run (all green)
- [ ] Downloaded `trivy-report` files from both runs, saved in an `evidence/` folder and pushed
- [ ] Architecture diagram (the Mermaid one in `README.md` renders on GitHub - screenshot it)
- [ ] SRS filled with team name and members (`docs/SRS.md`)
- [ ] README final check
