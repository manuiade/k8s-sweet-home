data "http" "tekton_pipeline_manifest" {
  url      = "https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml"
}

data "kubectl_file_documents" "tekton_pipeline_objects" {
  content  = data.http.tekton_pipeline_manifest.response_body
}

resource "kubectl_manifest" "tekton_pipeline" {
  for_each  = data.kubectl_file_documents.tekton_pipeline_objects.manifests
  yaml_body = each.value
}

resource "time_sleep" "wait_for_tekton" {
  create_duration = "60s"
  depends_on      = [kubectl_manifest.tekton_pipeline]
}

data "http" "tekton_triggers_manifest" {
  url      =  "https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml"
}

data "kubectl_file_documents" "tekton_triggers_objects" {
  content  = data.http.tekton_triggers_manifest.response_body
}

resource "kubectl_manifest" "tekton_triggers" {
  for_each  = data.kubectl_file_documents.tekton_triggers_objects.manifests
  yaml_body = each.value
  depends_on = [time_sleep.wait_for_tekton]
}

data "http" "tekton_interceptors_manifest" {
  url      =  "https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml"
}

data "kubectl_file_documents" "tekton_interceptors_objects" {
  content  = data.http.tekton_interceptors_manifest.response_body
}

resource "kubectl_manifest" "tekton_interceptors" {
  for_each  = data.kubectl_file_documents.tekton_interceptors_objects.manifests
  yaml_body = each.value
  depends_on = [time_sleep.wait_for_tekton]
}

data "http" "tekton_dashboard_manifest" {
  url      =  "https://storage.googleapis.com/tekton-releases/dashboard/latest/release-full.yaml"
}

data "kubectl_file_documents" "tekton_dashboard_objects" {
  content  = data.http.tekton_dashboard_manifest.response_body
}

resource "kubectl_manifest" "tekton_dashboard" {
  for_each  = data.kubectl_file_documents.tekton_dashboard_objects.manifests
  yaml_body = each.value
  depends_on = [time_sleep.wait_for_tekton]
}