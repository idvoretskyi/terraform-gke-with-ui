# Contributing to Terraform GKE with Monitoring

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## How to Contribute

### Reporting Issues

Before creating an issue, please:
- Check if the issue already exists
- Provide a clear description of the problem
- Include relevant terraform version and provider versions
- Include steps to reproduce the issue

### Pull Requests

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Add or update tests as necessary
5. Ensure all tests pass
6. Update documentation if needed
7. Submit a pull request

### Development Setup

1. Install required tools:
   - [Terraform](https://www.terraform.io/downloads.html) >= 1.0
   - [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)

2. Configure authentication:
   ```bash
   gcloud auth application-default login
   ```

3. Run tests:
   ```bash
   cd examples/simple
   terraform init
   terraform plan
   ```

### Coding Standards

- Follow Terraform best practices
- Use consistent variable naming
- Add validation where appropriate
- Include descriptions for all variables and outputs
- Use semantic versioning for releases

### Documentation

- Update README.md for any user-facing changes
- Add examples for new features
- Document any breaking changes

## Release Process

Releases are tagged following semantic versioning (semver). Only maintainers can create releases.

## Questions?

Feel free to open an issue for any questions about contributing.