package test

import (
	httphelper "github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"testing"
	"time"
)

func TestFunctionExecution(t *testing.T) {
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "..",
		Vars: map[string]interface{}{
			// needs to run on a valid GCP project id to pass
			"project": "",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	output := terraform.Output(t, terraformOptions, "function_url")
	assert.NotEmpty(t, output)
	httphelper.HttpGetWithRetry(t, output, nil, 200, "Hello World", 30, 5*time.Second)
}
