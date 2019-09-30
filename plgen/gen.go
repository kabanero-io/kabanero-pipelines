// Copyright © 2019 IBM Corporation and others.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package main

import (
	"fmt"
	"gopkg.in/yaml.v2"
	"os"
	"strconv"
	"strings"
)

var rindex int = 0

type PlGen struct {
	pr          PR
	pspecs      Spec
	psteps      []Steps
	plt         PipelineTask
	pl          Pipeline
	role        Role
	rolebinding RoleBinding
	plr         PipelineRun
}

type PipelineResourceParams struct {
	Name  string `yaml:"name"`
	Value string `yaml:"value"`
}

type PipelineResourceSpec struct {
	Type   string                 `yaml:"type"`
	Params PipelineResourceParams `yaml:"params"`
}

type Items struct {
	APIVersion string               `yaml:"apiVersion"`
	Kind       string               `yaml:"kind"`
	Metadata   Metadata             `yaml:"metadata"`
	Spec       PipelineResourceSpec `yaml:"spec"`
}

type PipelineRunResourceRef struct {
	Name string `yaml:"name"`
}

type PipelineRunResources struct {
	Name        string                 `yaml:"name"`
	ResourceRef PipelineRunResourceRef `string:"resourceRef"`
}

type PipelineRunTrigger struct {
	Type string `yaml:"type"`
}

type PipelineRunPipelineRef struct {
	Name string `yaml:"name"`
}

type PipelineRunSpec struct {
	ServiceAccount string                 `yaml:"serviceAccount"`
	Timeout        string                 `yaml:"timeout"`
	PipelineRef    PipelineRunPipelineRef `yaml:"pipelineRef"`
	Trigger        PipelineRunTrigger     `yaml:"trigger"`
	Resources      []PipelineRunResources `yaml:"resources,omitempty"`
}

type PipelineRun struct {
	APIVersion string          `yaml:"apiVersion"`
	Kind       string          `yaml:"kind"`
	Metadata   Metadata        `yaml:"metadata"`
	Spec       PipelineRunSpec `yaml:"spec"`
}

type Role struct {
	APIVersion string   `yaml:"apiVersion"`
	Kind       string   `yaml:"kind"`
	Metadata   Metadata `yaml:"metadata"`
}

type Subjects struct {
	Kind      string `yaml:"kind"`
	Name      string `yaml:"name"`
	Namespace string `yaml:"namespace"`
}

type RoleRef struct {
	Kind     string `yaml:"kind"`
	Name     string `yaml:"name"`
	APIGroup string `yaml:"apiGroup"`
}

type RoleBinding struct {
	APIVersion string   `yaml:"apiVersion"`
	Kind       string   `yaml:"kind"`
	Metadata   Metadata `yaml:"metadata"`
	Subjects   Subjects `yaml:"subjects"`
	RoleRef    RoleRef  `yaml:"roleRef"`
}

type Metadata struct {
	Name string `yaml:"name"`
}

type TaskRef struct {
	Name string `yaml:"name"`
	Kind string `yaml:"kind"`
}

type PipelineInputs struct {
	Name     string `yaml:"name"`
	Resource string `yaml:"resource"`
}

type PipelineOutputs struct {
	Name     string `yaml:"name"`
	Resource string `yaml:"resource"`
}

type PipelineResources struct {
	Inputs  []PipelineInputs  `yaml:"inputs,omitempty"`
	Outputs []PipelineOutputs `yaml:"outputs,omitempty"`
}

type Tasks struct {
	Name      string            `yaml:"name"`
	Taskref   TaskRef           `yaml:"taskRef"`
	Resources PipelineResources `yaml:"resources"`
	Params    []Params          `yaml:"params,omitempty"`
}

type PR struct {
	APIVersion string  `yaml:"apiVersion"`
	Items      []Items `yaml:"items"`
	Kind       string  `yaml:"kind"`
}

type Params struct {
	Name  string `yaml:"name"`
	Value string `yaml:"default"`
}

type Resources struct {
	Name string `yaml:"name"`
	Type string `yaml:"type"`
}

type Inputs struct {
	Resources []Resources `yaml:"resources,omitempty"`
	Params    []Params    `yaml:"params,omitempty"`
}

type Outputs struct {
	Resources []Resources `yaml:"resources,omitempty"`
	Params    []Params    `yaml:"params,omitempty"`
}

type Spec struct {
	Inputs  Inputs    `yaml:"inputs"`
	Outputs Outputs   `yaml:"outputs"`
	Steps   []Steps   `yaml:"steps,omitempty"`
	Volumes []Volumes `yaml:"volumes,omitempty"`
}

type Env struct {
	Name  string `yaml:"name"`
	Value string `yaml:"value"`
}

type Arg struct {
	Name  string `yaml:"name"`
	Value string `yaml:"value"`
}

type Mount struct {
	Name  string `yaml:"name"`
	Value string `yaml:"mountPath"`
}

type Cmd struct {
	Command string   `yaml:"command"`
	Args    []string `yaml:"args,omitempty"`
}

type HostPath struct {
	Path string `yaml:"path"`
	Type string `yaml:"type"`
}

type Volumes struct {
	Name     string   `yaml:"name"`
	HostPath HostPath `yaml:"hostPath"`
}

type Steps struct {
	Name  string  `yaml:"name"`
	Image string  `yaml:"image"`
	Env   []Env   `yaml:"env,omitempty"`
	Cmd   []Cmd   `yaml:"command,omitempty"`
	Mount []Mount `yaml:"volumeMounts,omitempty"`
	Arg   []Arg   `yaml:"arg,omitempty"`
}

type PipelineTask struct {
	APIVersion string   `yaml:"apiVersion"`
	Kind       string   `yaml:"kind"`
	Meta       Metadata `yaml:"metadata"`
	Spec       Spec     `yaml:"spec"`
}

type PipelineSpec struct {
	Resources []Resources `yaml:"resources,omitempty"`
	Tasks     Tasks       `yaml:"tasks"`
}

type Pipeline struct {
	APIVersion string       `yaml:"apiVersion"`
	Kind       string       `yaml:"kind"`
	Meta       Metadata     `yaml:"metadata"`
	Spec       PipelineSpec `yaml:"spec"`
}

// Marshals a GO struct into YAML definition
// and prints a --- separator. Any error, exit
func Marshal(in interface{}) {
	data, err := yaml.Marshal(in)
	if err != nil {
		fmt.Println("Error while marshalling into yaml:", err)
		os.Exit(1)
	}
	fmt.Print(string(data))
	fmt.Println("---")
}

// Generates a Role from a USER verb
func GenRole(plg PlGen) {
	role := plg.role
	Marshal(&role)
}

// Generates a RoleBinding from a USER verb
func GenRoleBinding(plg PlGen) {
	rolebinding := plg.rolebinding
	Marshal(&rolebinding)
}

// Generates a pipeline, binds it with a pipeline task
func GenPipeline(plg PlGen) {
	pl := plg.pl
	pl.APIVersion = apiVersion
	pl.Kind = "Pipeline"
	pl.Meta.Name = nomenClature + "-pipeline"
	pl.Spec.Tasks.Name = nomenClature
	pl.Spec.Tasks.Taskref.Name = nomenClature + "-task"
	Marshal(&pl)
}

// Generates a pipeline run, binds it with a pipeline
func GenPipelineRun(plg PlGen) {
	plr := plg.plr
	plr.APIVersion = apiVersion
	plr.Kind = "PipelineRun"
	plr.Metadata.Name = nomenClature + "-pipeline-run"
	plr.Spec.Timeout = pipelineTimeout
	plr.Spec.PipelineRef.Name = nomenClature + "-pipeline"
	plr.Spec.Trigger.Type = pipelineTrigger
	Marshal(&plr)
}

// Generates a pipeline task
func GenPipelineTask(plg PlGen) {
	plt := plg.plt
	plt.APIVersion = apiVersion
	plt.Kind = "Pipeline"
	plt.Meta.Name = nomenClature + "-task"
	Marshal(&plt)
}

// Generates a list of pipeline resources
func GenResource(plg PlGen) {
	pr := plg.pr
	pr.APIVersion = "v1"
	pr.Kind = "List"
	Marshal(&pr)
}

// Transform a RUN step. Basically:
// 1. Transalate any $ variables
// 2. suffix the commands under /bin/bash
func TransformRun(line string, step *Steps) {
	var v []string
	u := strings.Split(line, " ")[1:]
	for _, old := range u {
		if strings.HasPrefix(old, "$") {
			v = append(v, replace(step.Arg, old))
		} else {
			v = append(v, old)
		}
	}
	value := strings.Join(v, " ")
	step.Cmd = append(step.Cmd, Cmd{"[\"/bin/bash\"]", []string{"-c", value}})
	debuglog("processing RUN", u, "as", step.Cmd)
}

// Transform a USER verb.
// Create a Cluster Role
// Bind it with cluster-admin privilege
func TransformRole(line string, plg *PlGen) {
	name := strings.Split(line, " ")[1]
	var role Role
	var rolebinding RoleBinding
	role.APIVersion = "v1"
	role.Kind = "ServiceAccount"
	role.Metadata = Metadata{Name: name}

	var sub Subjects
	sub.Kind = role.Kind
	sub.Name = name
	sub.Namespace = namespace

	var roleref RoleRef
	roleref.Kind = "ClusterRole"
	roleref.Name = "cluster-admin"
	roleref.APIGroup = "rbac.authorization.k8s.io"

	rolebinding.APIVersion = "rbac.authorization.k8s.io/v1"
	rolebinding.Kind = "ClusterRoleBinding"
	rolebinding.Metadata.Name = rolebindingname
	rolebinding.Subjects = sub
	rolebinding.RoleRef = roleref

	plg.plr.Spec.ServiceAccount = role.Metadata.Name
	plg.role = role
	plg.rolebinding = rolebinding
	debuglog("processing USER", name, "as ClusterRoleBinding")
}

// Transform a MOUNT verb.
// For a MOUNT A=B:
// Create a volume with the name as _A_ and hostMount as A
// Create a voumeMount with name as _A_ and mountPath as B
func TransformMount(step *Steps, name string, val string, plg *PlGen) {
	mname := strings.ReplaceAll(name, "/", "_")
	step.Mount = append(step.Mount, Mount{Name: mname, Value: val})
	volumes := Volumes{Name: mname, HostPath: HostPath{Path: name, Type: "unknown"}}
	plg.pspecs.Volumes = append(plg.pspecs.Volumes, volumes)
	debuglog("processing MOUNT", mname, "as", volumes, "and", step.Mount)
}

// Main translation loop. As we are not mandating any specific order
// in the pipeline script, the top level PlGen object is pre-created
// and passed to this so that as and when data elements (more import-
// antly resources) are encountered, they can be attached to it.
func transformSteps(plg *PlGen, stepstr string, index int) {
	var step Steps
	lines := strings.Split(stepstr, "\n")
	for _, line := range lines {
		if line != "" {
			key := strings.Split(line, " ")[0]
			switch key {
			case "LABEL":
				step.Name = strings.Split(line, " ")[1]
				debuglog("processing LABEL", step.Name)
			case "FROM":
				step.Image = strings.Split(line, " ")[1]
				debuglog("processing FROM", step.Image)
			case "ARG", "ARGIN", "ARGOUT", "ENV", "MOUNT":
				value := strings.Split(line, " ")[1]
				name := strings.Split(value, "=")[0]
				val := strings.Split(value, "=")[1]
				if strings.HasPrefix(key, "ARG") {
					itemName := "resource" + strconv.Itoa(rindex)
					rindex++
					itemType := "image"
					if strings.HasPrefix(val, "http") {
						itemType = "url"
					}
					if strings.Contains(val, "github.com") {
						itemType = "git"
					}
					plg.pr.Items = append(plg.pr.Items, Items{
						APIVersion: "tekton.dev/v1alpha1",
						Kind:       "PipelineResource",
						Metadata:   Metadata{Name: name},
						Spec: PipelineResourceSpec{
							Params: PipelineResourceParams{
								Name:  itemName,
								Value: val,
							},
							Type: itemType,
						},
					})
					plg.plr.Spec.Resources = append(plg.plr.Spec.Resources, PipelineRunResources{Name: name, ResourceRef: PipelineRunResourceRef{Name: name}})
					plg.pl.Spec.Resources = append(plg.pl.Spec.Resources, Resources{Name: name, Type: itemType})
					if key == "ARGIN" || key == "ARG" {
						plg.pspecs.Inputs.Resources = append(plg.pspecs.Inputs.Resources, Resources{Name: name, Type: itemType})
						plg.pl.Spec.Tasks.Resources.Inputs = append(plg.pl.Spec.Tasks.Resources.Inputs, PipelineInputs{Name: name, Resource: itemType})
					} else {
						plg.pspecs.Outputs.Resources = append(plg.pspecs.Outputs.Resources, Resources{Name: name, Type: itemType})
						plg.pl.Spec.Tasks.Resources.Outputs = append(plg.pl.Spec.Tasks.Resources.Outputs, PipelineOutputs{Name: name, Resource: itemType})
					}
					step.Arg = append(step.Arg, Arg{Name: name, Value: val})
					debuglog("processing ARG", step.Arg)
				} else if key == "ENV" {
					step.Env = append(step.Env, Env{Name: name, Value: val})
					debuglog("processing ENV", step.Env)
				} else {
					TransformMount(&step, name, val, plg)
				}
			case "RUN":
				TransformRun(line, &step)
			case "USER":
				TransformRole(line, plg)
			default:
				fmt.Println("bad pipeline verb:", key)
			}
		}
	}
	plg.psteps = append(plg.psteps, step)
}
