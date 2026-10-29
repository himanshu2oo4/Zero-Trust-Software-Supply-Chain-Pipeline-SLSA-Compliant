CHECKS INSIDE OUR PIPELINE ----------------

Gitleaks used for -> Secret Scanning	 | inside -> Git commit history & code	 | "Did an engineer accidentally commit an AWS secret key or database password?"


Semgrep for ---> SAST (Static Analysis) scans Your Python source code	| "Did you write bad or dangerous code (like SQL injection or insecure logic)?"


Trivy (FS)	for SCA (Dependency Scan) scans	requirements.txt | "Are any third-party libraries known to have security flaws (CVEs)?"

Trivy (Image) for Container Vulnerability  scans Final Docker image	| "Does the underlying Linux OS in your container have any unpatched exploits?"

An SBOM is the machine-readable "ingredients list" of every single file, library, license, and OS package baked inside your Docker container.

🛠️ The Tool: Anchore Syft

To build our SBOM, we will use an industry-standard open-source tool called Syft (created by Anchore). It can look inside our compiled Docker image, catalog every single Python library, Debian package, and helper binary, and output a clean CycloneDX JSON file.

Kyverno is the guard standing directly at the Kubernetes API door. Before any pod is allowed to boot up on worker nodes, Kyverno intercepts the request, checks the container image against your cosign.pub public key, and asks: "Was this image signed by our official CI/CD pipeline?"
Signed: The Pod starts immediately.
Not Signed: Kubernetes rejects the request with a 403 Forbidden error. The container is never even pulled!



what in this project 
✅ Multi-stage hardened Docker build (non-root, minimal image)
✅ Secret scanning          → Gitleaks
✅ SAST                     → Semgrep
✅ Dependency scanning      → Trivy (filesystem)
✅ Container image scanning → Trivy (image)
✅ SBOM generation          → Syft (CycloneDX JSON)
✅ Image signing            → Cosign (key-based)
✅ Admission control        → Kyverno ClusterPolicy
✅ IaC provisioning         → Terraform (VPC + EKS)
✅ Dynamic image tagging    → Kustomize