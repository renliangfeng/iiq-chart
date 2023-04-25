@echo off
set /p env=Which environment ('sandbox', 'dev', 'test' or 'prod') would you like to deploye IIQ?

if "%env%" NEQ "sandbox" (
    if "%env%" NEQ "dev" (
        if "%env%" NEQ "test" (
			if "%env%" NEQ "prod" goto invalidEnv
		)
    )
)

echo Selected environment to build: %env%

set "type=ui"

if "%env%" EQU "sandbox" (
	goto printServerType
)

set /p type=Which type of IIQ Server ('ui', 'task') would you like to deploye? By default, 'ui' will be used.

if "%type%" NEQ "task" (
	if "%type%" NEQ "ui" goto invalidServerType
)

:printServerType (
	echo Selected IIQ Server Type: %type%
)

set releaseName=iiq-release-%type%

if "%type%" == "ui" (
	kubectl create namespace iiq
	kubectl create configmap iiq-config --from-file=env/%env%/iiq-properties/ --namespace iiq
)

helm install %releaseName% . --values ./values.yaml --values env/%env%/values.yaml --set fullnameOverride=iiq-app-%type% --namespace=iiq

goto theEnd

:invalidEnv (
    echo Invalid env input value
    goto theEnd
)

:invalidServerType (
    echo Invalid Server Type input value
    goto theEnd
)

:theEnd (
	echo Ending IIQ Deployment
)