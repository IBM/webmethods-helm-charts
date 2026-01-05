{{/*
Render extra containers
*/}}
{{- define "common.containers.extraContainers" -}}
{{- with .Values.extraContainers }}
{{- range . }}
- name: {{ .name | quote }}
  image: {{ tpl .image $ }}
  {{- if .command }}
  command:
  {{- if kindIs "slice" .command }}
  {{- range .command }}
    - {{ tpl . $ | quote }}
  {{- end }}
  {{- else }}
    - {{ tpl .command $ | quote }}
  {{- end }}
  {{- end }}
  {{- if .args }}
  args: 
  {{- range .args }}
    - {{ tpl . $ | quote }}
  {{- end }}
  {{- end }}
  {{- if .env }}
  env:
  {{- range .env }}
  - name: {{ .name }}
    value: {{ tpl .value $ | quote }}
  {{- end }}
  {{- end }}  
  ports:
    {{- range .ports }}
    - name: {{ .name | quote }}
      containerPort: {{ .containerPort }}
      {{- if .protocol }}
      protocol: {{ tpl .protocol $ }}
      {{- end }}
    {{- end }}
  volumeMounts:
    {{- range .volumeMounts }}
    - name: {{ .name }}
      mountPath: {{ tpl .mountPath $ }}
      {{- if .subPath }}
      subPath: {{ tpl .subPath $ }}
      {{- end }}
    {{- end }}
  resources:
    {{- if .resources }}
    limits:
      {{- if .resources.limits }}
      {{- toYaml .resources.limits | nindent 14 }}
      {{- end }}
    requests:
      {{- if .resources.requests }}
      {{- toYaml .resources.requests | nindent 14 }}
      {{- end }}
    {{- end }}
  livenessProbe:
    {{- if .livenessProbe }}
    {{- toYaml .livenessProbe | nindent 12 }}
    {{- end }}
  readinessProbe:
    {{- if .readinessProbe }}
    {{- toYaml .readinessProbe | nindent 12 }}
    {{- end }}
  securityContext:
    {{- if .securityContext }}
    {{- toYaml .securityContext | nindent 12 }}
    {{- end }}
  {{- if .imagePullPolicy }}
  imagePullPolicy: {{ tpl .imagePullPolicy $ }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}