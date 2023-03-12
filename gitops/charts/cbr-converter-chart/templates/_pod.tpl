{{- define "pod" }}
containers:
  - name: {{ .parent.name }}
    image: {{ .parent.image }}:{{ .parent.tag }}
    imagePullPolicy: {{- if not (empty .parent.pullPolicy) }} {{.parent.pullPolicy}}
    {{- else }} Always
    {{- end }}
   {{ if .parent.port }}
    ports:
    - containerPort: {{ .parent.port }}
   {{ end }}
   {{- if or (not (empty .parent.secretEnvs)) (not (empty .parent.envs))}}
    env:
      {{- range $secret := .parent.secretEnvs }}
      - name: {{$secret.envName}}
        valueFrom:
          secretKeyRef:
            name: {{$secret.name}}
            key: {{$secret.key}}
      {{- end}}
      {{- range $key, $value := .parent.envs }}
      - name: {{ $key }}
        value: {{$value}}
      {{- end}}
    {{- end}}
    {{- if not (empty .parent.configMaps)}}
    envFrom:
      {{- range  $cm_name := .parent.configMaps }}
      - configMapRef:
          name: {{$cm_name}}
       {{- end }}
    {{- end}}
    {{- with .parent.livenessProbe }}
    livenessProbe:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- with .parent.readinessProbe }}
    readinessProbe:
    {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- if .parent.command }}
    command: [ "/bin/sh", "-c" ]
    args:
    - >
    {{- $len := (len .parent.command)}}
    {{- $list := .parent.command}}
    {{- range $index, $element := $list}}
        {{ . }}{{if ne $index (sub $len 1)}} && {{end}}
    {{- end }}
    {{- end }}

{{- end }}
