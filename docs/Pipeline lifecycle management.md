# Pipeline lifecycle management

Kabanero pipelines activated in the cluster are not versioned today.  If you try to activate a Kabnero CR for two version of the same stack with two different versions of pipelines with the same pipeline names, the results of which pipeline will get activated is undefined.

If you want to try to develop and test a new set of pipelines there are two paths you can follow:

- You give the pipelines and associated artifacts a different name.  For example, appending `-v2` to the names.  Create the pipelines release with the new names and add the new pipelines release to your Kabanero CR to activate it.  Update your web hooks to point to the new pipeline names.
- Update your Kabanero CR to point to the updated pipeline release for all stack versions to have a consistent behavior.

A more simplified mechanism to support multiple  pipeline versions for multiple versions of the same stack will be provided in future releases of Kabanero.
