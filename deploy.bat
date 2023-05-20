@echo off
set /p env=Which environment ('sandbox', 'development', 'test' or 'prod') would you like to deploye IIQ?

if "%env%" NEQ "sandbox" (
    if "%env%" NEQ "development" (
        if "%env%" NEQ "test" (
			if "%env%" NEQ "prod" goto invalidEnv
		)
    )
)

echo Selected environment to build: %env%

set releaseName=iiq

kubectl create namespace iiq

helm install %releaseName% . --values ./values.yaml --values env/%env%/values.yaml --namespace=iiq

goto theEnd

:invalidEnv (
    echo Invalid env input value
    goto theEnd
)

:theEnd (
	echo Ending IIQ Deployment
)