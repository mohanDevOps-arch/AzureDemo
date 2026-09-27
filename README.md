# DevOps Demo App

A tiny Flask + HTML app used to demo Azure DevOps end to end at zero cost:
Boards → Repos → Pipelines → Tests → Artifacts → Environments (dev/prod with approval).

## Run locally
```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements-dev.txt
pytest                      # run tests
python -m app               # open http://localhost:8000
```

## Endpoints
| Path | What it returns |
|---|---|
| `/` | HTML page showing environment, version and build ID |
| `/health` | `{"status": "UP"}` - used by the deploy smoke test |
| `/api/info` | JSON with the same details as the page |

## Layout
```
app/               Flask app, HTML template, CSS
tests/             pytest unit tests
scripts/deploy.sh  deploys the build on the self-hosted agent machine
azure-pipelines.yml  multi-stage CI/CD pipeline
```

See the step-by-step guide for the full Azure DevOps setup.
