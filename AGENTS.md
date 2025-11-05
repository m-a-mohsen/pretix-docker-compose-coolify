# AGENTS.md

## Build Commands
- `docker-compose up -d --build --force-recreate` - Build and start all containers
- `docker-compose down` - Stop all containers
- `docker-compose logs -f app` - Follow application logs

## Testing
No formal test suite. Test by:
1. Running `docker-compose up -d --build --force-recreate`
2. Accessing via Coolify-assigned domain (HTTP/HTTPS auto-handled)
3. Verifying Pretix web interface loads correctly

## Code Style Guidelines

### Python (cron.py)
- Use type hints for function parameters and return values
- Follow PEP 8 naming conventions (snake_case for variables/functions)
- Use docstrings with triple quotes for all functions
- Import standard library modules first, then third-party
- Use logging for debug/info/error messages
- Handle exceptions gracefully with try/except blocks

### Configuration Files
- Use INI format for Pretix config (pretix.cfg)
- Comment lines with semicolon (;) in config files
- Keep sensitive values (passwords, keys) as placeholders

### Shell Scripts
- Use `#!/bin/sh` shebang for portability
- Quote variables: `"$path"` not `$path`
- Use echo statements for debugging output
- Exit with proper error codes on failure

### Docker/Nginx
- Use official base images where possible
- Follow Dockerfile best practices (USER, EXPOSE, ENTRYPOINT)
- Use specific Nginx directives for security headers
- Configure gzip compression for static assets