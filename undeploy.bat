@echo off
@REM set releaseName=iiq-release

@REM helm uninstall %releaseName% --namespace iiq
kubectl delete namespace iiq
@REM kubectl delete configmap iiq-config