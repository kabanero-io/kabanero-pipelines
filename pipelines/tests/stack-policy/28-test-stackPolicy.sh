#!/bin/bash 

VARIATION="Variation#28"

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

# Write .appsody-config.yamk
cat <<- "EOF" > .appsody-config.yaml
stack: kabanerobeta/java-microprofile:1.0.1
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
