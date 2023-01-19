# This is a special file which will not be submitted to the api
# Calling the defined functions simply adds the declaration over that line instead of declaring them at that point

{{- define "common.labels" }}
labels:
  chartName: {{ .Chart.Name }}
  chartVersion: {{ .Chart.Version }}
{{- end }}