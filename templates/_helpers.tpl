{{/*
Provides a consistent set of default labels for the pods in the chart
Note that the context provided when including this template needs to include
a "serverType" key, with a value of i.e. "ui" or "task"
*/}}
{{- define "defaultPodLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}-{{ .serverType }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "configuredLabels" }}
{{- if (hasKey .Values "labels")}}
{{- .Values.labels | toYaml }}
{{- end }}
{{- end }}

{{- define "podLabels" }}
{{- default (include "defaultPodLabels" .) (include "configuredLabels" .) . }}
{{- end }}

{{- define "sslMode" }}
{{- .Values.database.useSSL | ternary "VERIFY_CA" "DISABLED" }}
{{- end }}