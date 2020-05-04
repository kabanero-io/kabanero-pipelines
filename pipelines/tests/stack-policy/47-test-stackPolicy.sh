#!/bin/bash 

VARIATION="Variation#27"

# Source logging constants and functions
. ./log.sh

# Write mock data from kabanero operator
cat <<- "EOF" > kubectl_kabanero.txt
{
    "apiVersion": "kabanero.io/v1alpha2",
    "kind": "Kabanero",
    "metadata": {
        "annotations": {
            "kubectl.kubernetes.io/last-applied-configuration": "{\"apiVersion\":\"kabanero.io/v1alpha2\",\"kind\":\"Kabanero\",\"metadata\":{\"annotations\":{},\"name\":\"kabanero\",\"namespace\":\"kabanero\"},\"spec\":{\"stacks\":{\"pipelines\":[{\"https\":{\"url\":\"https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz\"},\"id\":\"default\",\"sha256\":\"3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d\"}],\"repositories\":[{\"https\":{\"url\":\"https://github.com/kabanero-io/kabanero-stack-hub/releases/download/0.8.0/kabanero-stack-hub-index.yaml\"},\"name\":\"central\"}]},\"version\":\"0.8.0\"}}\n"
        },
        "creationTimestamp": "2020-04-23T15:26:32Z",
        "finalizers": [
            "kabanero.io.kabanero-operator"
        ],
        "generation": 2,
        "name": "kabanero",
        "namespace": "kabanero",
        "resourceVersion": "2613100",
        "selfLink": "/apis/kabanero.io/v1alpha2/namespaces/kabanero/kabaneros/kabanero",
        "uid": "1c58397e-c5ce-4a92-8b33-d536d21b9f9f"
    },
    "spec": {
        "admissionControllerWebhook": {},
        "cliServices": {},
        "codeReadyWorkspaces": {
            "enable": false,
            "operator": {
                "customResourceInstance": {
                    "devFileRegistryImage": {}
                }
            }
        },
        "collectionController": {},
        "events": {},
        "github": {},
        "governancePolicy": {
            "stackPolicy": "ignoreDigest"
        },
        "landing": {},
        "sso": {},
        "stackController": {},
        "stacks": {
            "pipelines": [
                {
                    "gitRelease": {},
                    "https": {
                        "url": "https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz"
                    },
                    "id": "default",
                    "sha256": "3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d"
                }
            ],
            "repositories": [
                {
                    "gitRelease": {},
                    "https": {
                        "url": "https://github.com/kabanero-io/kabanero-stack-hub/releases/download/0.8.0/kabanero-stack-hub-index.yaml"
                    },
                    "name": "central"
                }
            ]
        },
        "version": "0.8.0"
    },
    "status": {
        "admissionControllerWebhook": {
            "ready": "True"
        },
        "appsody": {
            "ready": "True",
            "version": "0.4.0"
        },
        "cli": {
            "hostnames": [
                "kabanero-cli-kabanero.apps.loners.os.fyre.ibm.com"
            ],
            "ready": "True"
        },
        "collectionController": {
            "ready": "True",
            "version": "0.8.0"
        },
        "kabaneroInstance": {
            "ready": "True",
            "version": "0.8.0"
        },
        "landing": {
            "ready": "True",
            "version": "0.8.0"
        },
        "serverless": {
            "knativeServing": {
                "ready": "True",
                "version": "0.12.1"
            },
            "ready": "True",
            "version": "1.5.0"
        },
        "sso": {
            "configured": "False",
            "ready": "False"
        },
        "stackController": {
            "ready": "True",
            "version": "0.8.0"
        },
        "tekton": {
            "ready": "True",
            "version": "v0.10.1"
        }
    }
}
EOF

# Write mock data from kabanero operator get stack
cat <<- "EOF" > kubectl_stack.txt
{
    "apiVersion": "kabanero.io/v1alpha2",
    "kind": "Stack",
    "metadata": {
        "creationTimestamp": "2020-04-23T15:26:52Z",
        "finalizers": [
            "kabanero.io/stack-controller"
        ],
        "generation": 2,
        "name": "java-microprofile",
        "namespace": "kabanero",
        "ownerReferences": [
            {
                "apiVersion": "kabanero.io/v1alpha2",
                "controller": true,
                "kind": "Kabanero",
                "name": "kabanero",
                "uid": "1c58397e-c5ce-4a92-8b33-d536d21b9f9f"
            }
        ],
        "resourceVersion": "6935568",
        "selfLink": "/apis/kabanero.io/v1alpha2/namespaces/kabanero/stacks/java-microprofile",
        "uid": "8024edb2-c94e-48cd-b33b-7a32fd47ca9d"
    },
    "spec": {
        "name": "java-microprofile",
        "versions": [
            {
                "images": [
                    {
                        "id": "Eclipse MicroProfile®",
                        "image": "docker.io/kabanerobeta/java-microprofile"
                    }
                ],
                "pipelines": [
                    {
                        "gitRelease": {},
                        "https": {
                            "url": "https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz"
                        },
                        "id": "default",
                        "sha256": "3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d"
                    }
                ],
                "version": "0.2.26"
            },
            {
                "images": [
                    {
                        "id": "Eclipse MicroProfile®",
                        "image": "docker.io/kabanero/java-microprofile"
                    }
                ],
                "pipelines": [
                    {
                        "gitRelease": {},
                        "https": {
                            "url": "https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz"
                        },
                        "id": "default",
                        "sha256": "3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d"
                    }
                ],
                "version": "0.2.25"
            }
        ]
    },
    "status": {
        "summary": "[ 0.2.26: active, 0.2.25: active ]",
        "versions": [
            {
                "images": [
                    {
                        "digest": {
                            "activation": "37cdf72ab9589e4b0f1389e1c6acc574a1aa8c9cc2234f6be3fd2e994e1de93f"
                        },
                        "id": "Eclipse MicroProfile®",
                        "image": "docker.io/kabanerobeta/java-microprofile"
                    }
                ],
                "pipelines": [
                    {
                        "activeAssets": [
                            {
                                "assetDigest": "88e9b5dc9500b980290e3269ad08eaf424b22badaf09eb96542e474694ad8e2e",
                                "assetName": "java-microprofile-build-push-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "76132576089c1e0d98d951c23fbfa9a48e14b04ee129a48976e9092455de0a02",
                                "assetName": "java-microprofile-utilities-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "ebca36e65840ea2e9bc4e2172191d38cadd03827e31d29a58e813c3bc215d902",
                                "assetName": "java-microprofile-build-push-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9da4a76314d124d3526cfa7e9c244fc7022db00be937e84b60191dc20595c754",
                                "assetName": "java-microprofile-build-deploy-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "32046f8e8b03780059e113a27213cde205ae2e971d8274b3bbbb8269018f9da3",
                                "assetName": "java-microprofile-deployment-condition",
                                "group": "tekton.dev",
                                "kind": "Condition",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "d325722e7309cd84fdb0362267a3fe3825af896711e71863d17382135ef28a1e",
                                "assetName": "java-microprofile-build-deploy-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "b0e5e4ee5342d61ae47f803f2858e83028bfa3086614763ecda41527cafacae0",
                                "assetName": "java-microprofile-build-push-jk-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "dc917c4e24cabaaa42afbb588a779737dc2187e731d661a64d85e2fa8384be7d",
                                "assetName": "java-microprofile-image-scan-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "34f67de6458734029a09a93339f58b36ce99565a79c8ed4e923099619a557ec7",
                                "assetName": "java-microprofile-image-retag-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc9bb051784d76c7a71cfdad6857b05a758995746c4dcab04cbf0c34c331286d",
                                "assetName": "java-microprofile-build-push-jk-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "19afa906601d3a763ac1bd9ab9d0644de86646db33ed6f4e99be30059df2c69b",
                                "assetName": "java-microprofile-image-retag-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "e54ece6a064544dd991386ca947fbda5d917f0cad0d6a7a48bbee0848bfe5060",
                                "assetName": "java-microprofile-build-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "8203b88c5699550e1a6633dc67ebc5a3187aa516e08b3f4973047bb7845f16bb",
                                "assetName": "java-microprofile-validate-stack-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "3361059f6e75b94ad6a644e5a8e266c038788dfcbf112753d281d38fa36108b0",
                                "assetName": "java-microprofile-build-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "8ffe897f65ee70d8f72c240f8bcc405d1ce04099124e6eb15b8b36d6ee38ff37",
                                "assetName": "java-microprofile-deploy-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            }
                        ],
                        "digest": "3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d",
                        "gitRelease": {},
                        "name": "default",
                        "url": "https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz"
                    }
                ],
                "status": "active",
                "version": "0.2.26"
            },
            {
                "images": [
                    {
                        "digest": {
                            "activation": "9e69ab0182cf6301867f5b597828b35a72d15791aafe54fd8396ff2d7b0b9acb"
                        },
                        "id": "Eclipse MicroProfile®",
                        "image": "docker.io/kabanero/java-microprofile"
                    }
                ],
                "pipelines": [
                    {
                        "activeAssets": [
                            {
                                "assetDigest": "88e9b5dc9500b980290e3269ad08eaf424b22badaf09eb96542e474694ad8e2e",
                                "assetName": "java-microprofile-build-push-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "76132576089c1e0d98d951c23fbfa9a48e14b04ee129a48976e9092455de0a02",
                                "assetName": "java-microprofile-utilities-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "ebca36e65840ea2e9bc4e2172191d38cadd03827e31d29a58e813c3bc215d902",
                                "assetName": "java-microprofile-build-push-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9da4a76314d124d3526cfa7e9c244fc7022db00be937e84b60191dc20595c754",
                                "assetName": "java-microprofile-build-deploy-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "32046f8e8b03780059e113a27213cde205ae2e971d8274b3bbbb8269018f9da3",
                                "assetName": "java-microprofile-deployment-condition",
                                "group": "tekton.dev",
                                "kind": "Condition",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "9632a4a4d90a90431b8e822dfeb11e79ba7944ca5b24a33ddd89d02e2d0fb278",
                                "assetName": "java-microprofile-build-push-jk-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "d325722e7309cd84fdb0362267a3fe3825af896711e71863d17382135ef28a1e",
                                "assetName": "java-microprofile-build-deploy-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "b0e5e4ee5342d61ae47f803f2858e83028bfa3086614763ecda41527cafacae0",
                                "assetName": "java-microprofile-build-push-jk-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "236bcf3f3126db48364a1fe66741de54111635aa3b802d6904b34ccec43ae052",
                                "assetName": "java-microprofile-build-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "dc917c4e24cabaaa42afbb588a779737dc2187e731d661a64d85e2fa8384be7d",
                                "assetName": "java-microprofile-image-scan-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "34f67de6458734029a09a93339f58b36ce99565a79c8ed4e923099619a557ec7",
                                "assetName": "java-microprofile-image-retag-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "2e18695b386f73a4a073bf402104d1151b1becf36838defa4375c8f5181128c2",
                                "assetName": "java-microprofile-build-deploy-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc9bb051784d76c7a71cfdad6857b05a758995746c4dcab04cbf0c34c331286d",
                                "assetName": "java-microprofile-build-push-jk-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "19afa906601d3a763ac1bd9ab9d0644de86646db33ed6f4e99be30059df2c69b",
                                "assetName": "java-microprofile-image-retag-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "e54ece6a064544dd991386ca947fbda5d917f0cad0d6a7a48bbee0848bfe5060",
                                "assetName": "java-microprofile-build-pl",
                                "group": "tekton.dev",
                                "kind": "Pipeline",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "8203b88c5699550e1a6633dc67ebc5a3187aa516e08b3f4973047bb7845f16bb",
                                "assetName": "java-microprofile-validate-stack-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "3361059f6e75b94ad6a644e5a8e266c038788dfcbf112753d281d38fa36108b0",
                                "assetName": "java-microprofile-build-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "8ffe897f65ee70d8f72c240f8bcc405d1ce04099124e6eb15b8b36d6ee38ff37",
                                "assetName": "java-microprofile-deploy-task",
                                "group": "tekton.dev",
                                "kind": "Task",
                                "namespace": "kabanero",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-pullrequest-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-push-binding",
                                "group": "tekton.dev",
                                "kind": "TriggerBinding",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            },
                            {
                                "assetDigest": "fc451d39a3dacac4e82044d1195a5553115e5953965326bc41227c0d1bba4d6a",
                                "assetName": "java-microprofile-build-push-pl-template",
                                "group": "tekton.dev",
                                "kind": "TriggerTemplate",
                                "namespace": "tekton-pipelines",
                                "status": "active",
                                "version": "v1alpha1"
                            }
                        ],
                        "digest": "3f3e440b3eed24273fd43c40208fdd95de6eadeb82b7bb461f52e1e5da7e239d",
                        "gitRelease": {},
                        "name": "default",
                        "url": "https://github.com/kabanero-io/kabanero-pipelines/releases/download/0.8.0/default-kabanero-pipelines.tar.gz"
                    }
                ],
                "status": "active",
                "version": "0.2.25"
            }
        ]
    }
}
EOF


# This response does double duty, it looks like both a stack image and an application image
# this is so that we don't have to mock up two different reponses 
cat <<- "EOF" > skopeo.txt
{
    "Name": "docker.io/kabanerbeta/java-microprofile",
    "Digest": "sha256:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF",
    "RepoTags": [
        "latest"
    ],
    "Created": "2020-04-21T21:57:06.723716338Z",
    "DockerVersion": "",
    "Labels": {
        "architecture": "x86_64",
        "authoritative-source-url": "registry.access.redhat.com",
        "build-date": "2019-10-29T16:44:53.794580",
        "com.redhat.build-host": "cpt-1002.osbs.prod.upshift.rdu2.redhat.com",
        "com.redhat.component": "ubi8-container",
        "com.redhat.license_terms": "https://www.redhat.com/en/about/red-hat-end-user-license-agreements#UBI",
        "description": "This image is the Kabanero development container for the java-microprofile stack",
        "dev.appsody.image.commit.author": "Scott McClements \u003c31139144+smcclem@users.noreply.github.com\u003e",
        "dev.appsody.image.commit.committer": "GitHub \u003cnoreply@github.com\u003e",
        "dev.appsody.image.commit.date": "Mon Apr 6 14:47:12 2020 -0400",
        "dev.appsody.image.commit.message": "Update .appsody-config.yaml",
        "dev.appsody.stack.authors": "Emily Jiang \u003cemijiang6@googlemail.com\u003e, Neeraj Laad \u003cneeraj.laad@gmail.com\u003e, Ozzy \u003cozzy@ca.ibm.com\u003e",
        "dev.appsody.stack.commit.author": "kilnerm \u003c38245247+kilnerm@users.noreply.github.com\u003e",
        "dev.appsody.stack.commit.committer": "GitHub \u003cnoreply@github.com\u003e",
        "dev.appsody.stack.commit.contextDir": "/incubator/java-microprofile",
        "dev.appsody.stack.commit.date": "Fri Apr 3 09:22:57 2020 +0100",
        "dev.appsody.stack.commit.message": "Merge pull request #316 from groeges/release-0.6",
        "dev.appsody.stack.configured": "docker.io/kabanerobeta/java-microprofile:0.2",
        "dev.appsody.stack.created": "2020-04-03T08:26:27Z",
        "dev.appsody.stack.description": "Eclipse MicroProfile on Open Liberty \u0026 OpenJ9 using Maven",
        "dev.appsody.stack.documentation": "https://github.com/kabanero-io/collections/tree/master/incubator/java-microprofile/README.md",
        "dev.appsody.stack.id": "java-microprofile",
        "dev.appsody.stack.digest": "sha256:37cdf72ab9589e4b0f1389e1c6acc574a1aa8c9cc2234f6be3fd2e994e1de93f",
        "dev.appsody.stack.licenses": "Apache-2.0",
        "dev.appsody.stack.revision": "27a3254c80e6c5367a76e6099c2e18b393d15841",
        "dev.appsody.stack.source": "https://github.com/kabanero-io/collections/tree/master/incubator/java-microprofile/image",
        "dev.appsody.stack.tag": "docker.io/kabanerobeta/java-microprofile:0.2.26",
        "dev.appsody.stack.title": "Eclipse MicroProfile®",
        "dev.appsody.stack.url": "https://github.com/kabanero-io/collections/tree/master/incubator/java-microprofile",
        "dev.appsody.stack.version": "0.2.26",
        "distribution-scope": "public",
        "io.k8s.description": "The Universal Base Image is designed and engineered to be the base layer for all of your containerized applications, middleware and utilities. This base image is freely redistributable, but Red Hat only supports Red Hat technologies through subscriptions for Red Hat products. This image is maintained by Red Hat and updated regularly.",
        "io.k8s.display-name": "Red Hat Universal Base Image 8",
        "io.openshift.expose-services": "",
        "io.openshift.tags": "base rhel8",
        "maintainer": "Red Hat, Inc.",
        "name": "kabanero/java-microprofile",
        "org.opencontainers.image.authors": "Arthur De Magalhaes, Chris Potter",
        "org.opencontainers.image.created": "2020-04-21T21:51:53Z",
        "org.opencontainers.image.documentation": "https://github.com/smcclem/java-microprofile",
        "org.opencontainers.image.revision": "ed1596c377ccd988679ac90721f0bb64bf63d815-modified-not-pushed",
        "org.opencontainers.image.source": "https://github.com/smcclem/java-microprofile/tree/master",
        "org.opencontainers.image.title": "git-source",
        "org.opencontainers.image.url": "https://github.com/smcclem/java-microprofile",
        "org.opencontainers.image.vendor": "Open Liberty",
        "org.opencontainers.image.version": "19.0.0.12",
        "release": "277",
        "run": "docker run --rm -ti \u003cimage_name:tag\u003e /bin/bash",
        "summary": "Image for Kabanero java-microprofile development",
        "url": "https://access.redhat.com/containers/#/registry.access.redhat.com/ubi8/images/8.1-277",
        "vcs-ref": "c42933bcdbf9f1c232e981a5e40de257c3534c8e",
        "vcs-type": "git",
        "vendor": "Kabanero",
        "version": "0.2.26"
    },
    "Architecture": "amd64",
    "Os": "linux",
    "Layers": [
        "sha256:0bb54aa5e97745c8692f6fc54dadca5b4b645a724ba5df96ecb762626d083981",
        "sha256:941e1e2b31a86bf0d41d8964e6f0559267859fe3893b518b0dbd605c60c1ffe7",
        "sha256:7f20732c17c59f6561749c28bde5564b47ce1b44ce7915b997ad50627c831abf",
        "sha256:83b699b12264ee212ee599288219a12e8d8571412c6e630447693887eda09422",
        "sha256:295ebc8593e501aac1c38c4f5ff02d7d4f8fbe81455d4f4f2b52eb5d7ba23eac",
        "sha256:642c3ffd0d27b5d2f305ca49f96d0c55184e70f12394e03dcc079dd5520b18a6",
        "sha256:f10c9f439b46d5cd77f3379a7f7cde3ad879c33f586a41165eea74384b2dcd80",
        "sha256:0a0934cc953ddb7e2d689cda705a1a63659c1026fac75d99407ddb0df9409ff3",
        "sha256:79aa6a5fe1ef94708f16498dc07d9bb9cf3a790f20fa91d8acc786547b9ea8fa",
        "sha256:f747530fce6e671944a076c212d44e9f9137e2492ae9616511f4e26147dff4aa"
    ]
}
EOF

# Write .appsody-config.yamk
cat <<- "EOF" > .appsody-config.yaml
stack: kabanerobeta/java-microprofile:1.0
EOF

export gitsource=.

#####################################
# Pre-build stackPolicy enforcement #
#####################################
log $INFO "[$VARIATION]: Test pre-build stackPolicy enforcement"
./mock.sh ./enforce_stack_policy.sh pre-build > enforce_stack_policy.out 2>&1
RC=$?
cat enforce_stack_policy.out

grep -q "Enforcing 'stackPolicy' of 'ignoreDigest'" enforce_stack_policy.out 
if [ "$?" == "0" ]; then
   log $INFO "[$VARIATION]: stackPolicy is valid."         
else
   log $ERROR "[$VARIATION]: Failed. Expected stackPolicy not found."
   exit 1
fi

if [ "$RC" == "1" ]; then
   log $INFO "[$VARIATION]: stackPolicy correctly failed."       
else
   log $ERROR "[$VARIATION]: stackPolicy incorrectly passed."
   exit 1
fi

rm enforce_stack_policy.out

# Cleanup 
rm .appsody-config.yaml
rm kubectl_kabanero.txt
rm kubectl_stack.txt
rm skopeo.txt

