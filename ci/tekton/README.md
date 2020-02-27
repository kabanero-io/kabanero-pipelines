
Use these steps to trigger a Tekton pipeline build of your pipelines repository. The pipeline will build the pipelines and deploy a `pipelines-index` container into your cluster. The `pipelines-index` container hosts the Kabanero pipeline artifacts.

1. Deploy pipeline
    ```
    oc -n kabanero apply -f tekton/pipelines-build-pipeline.yaml 
    ```
1. Deploy task
    ```
    oc -n kabanero apply -f tekton/pipelines-build-task.yaml 
    ```

1. Configure security constraints for service account `pipelines-index`
    ```
    oc -n kabanero adm policy add-scc-to-user privileged -z pipelines-index
    ```

1. Create `pipelines-build-git-resource.yaml` file with the following contents. Modify `revision` and `url` properties as needed. 
    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineResource
    metadata:
      name: pipelines-build-git-resource
    spec:
      params:
      - name: revision
        value: master
      - name: url
        value: https://github.com/kabanero-io/kabanero-pipelines.git
      type: git
    ```

1. Deploy the `pipelines-build-git-resource.yaml` file via `oc -n kabanero apply -f pipelines-build-git-resource.yaml`

1. Create `pipelines-build-pipeline-run.yaml` file with the following contents.

    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineRun
    metadata:
      name: pipelines-build-pipeline-run
      namespace: kabanero
    spec:
      pipelineRef:
        name: pipelines-build-pipeline
      resources:
      - name: git-source
        resourceRef:
          name: pipelines-build-git-resource
      params:
        - name: deploymentSuffix
          value: latest
      serviceAccountName: pipelines-index
      timeout: 60m
    ```

1. If you are using GitHub Enterprise, [create a secret](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git) and associate it with the `pipelines-index` service account. For example:
    ```
    oc -n kabanero secrets link pipelines-index basic-user-pass
    ```

1. Trigger pipeline
    ```
    oc -n kabanero delete --ignore-not-found -f pipelines-build-pipeline-run.yaml
    sleep 5
    oc -n kabanero apply -f pipelines-build-pipeline-run.yaml
    ```

    You can track the pipeline execution in the Tekton dashboard or via CLI:
    ```
    oc -n kabanero logs $(oc -n kabanero get pod -o name -l tekton.dev/task=pipelines-build-task) --all-containers -f 
    ```

   After the build completes successfully, a `pipelines-index-latest` container is deployed into your cluster.

1. Get the route for the `pipelines-index-latest` pod and use it to generate pipelines URL:

    ```
    PIPELINES_URL=$(oc -n kabanero get route pipelines-index-latest --no-headers -o=jsonpath='https://{.status.ingress[0].host}/default-kabanero-pipelines.tar.gz')
    echo $PIPELINES_URL
    ```

1. Follow the [configuring a Kabanero CR instance](https://kabanero.io/docs/ref/general/configuration/kabanero-cr-config.html) documentation to configure or deploy a Kabanero instance with the `PIPELINES_URL` obtained in the previous step. 
