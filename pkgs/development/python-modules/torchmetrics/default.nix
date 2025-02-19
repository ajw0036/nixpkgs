{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, numpy
, lightning-utilities
, cloudpickle
, scikit-learn
, scikit-image
, packaging
, psutil
, py-deprecate
, torch
, pytestCheckHook
, torchmetrics
, pytorch-lightning
, pytest-doctestplus
, pytest-xdist
}:

let
  pname = "torchmetrics";
  version = "1.3.0";
in
buildPythonPackage {
  inherit pname version;
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "Lightning-AI";
    repo = "torchmetrics";
    rev = "refs/tags/v${version}";
    hash = "sha256-xDUT9GSOn6ZNDFRsFws3NLxBsILKDHPKeEANwM8NXj8=";
  };

  patches = [
    # The extra dependencies dictionary contains an illegally named entry '_tests'.
    # The build fails because of this.
    # Issue has been opened upstream: https://github.com/Lightning-AI/torchmetrics/issues/2305
    ./0001-remove-illegal-name-from-extra-dependencies.patch
  ];

  propagatedBuildInputs = [
    numpy
    lightning-utilities
    packaging
    py-deprecate
  ];

  # Let the user bring their own instance
  buildInputs = [
    torch
  ];

  nativeCheckInputs = [
    pytorch-lightning
    scikit-learn
    scikit-image
    cloudpickle
    psutil
    pytestCheckHook
    pytest-doctestplus
    pytest-xdist
  ];

  # A cyclic dependency in: integrations/test_lightning.py
  doCheck = false;
  passthru.tests.check = torchmetrics.overridePythonAttrs (_: {
    pname = "${pname}-check";
    doCheck = true;
    # We don't have to install because the only purpose
    # of this passthru test is to, well, test.
    # This fixes having to set `catchConflicts` to false.
    dontInstall = true;
  });

  disabledTests = [
    # `IndexError: list index out of range`
    "test_metric_lightning_log"
  ];

  disabledTestPaths = [
    # These require too many "leftpad-level" dependencies
    # Also too cross-dependent
    "tests/unittests"

    # A trillion import path mismatch errors
    "src/torchmetrics"
  ];

  pythonImportsCheck = [
    "torchmetrics"
  ];

  meta = with lib; {
    description = "Machine learning metrics for distributed, scalable PyTorch applications (used in pytorch-lightning)";
    homepage = "https://lightning.ai/docs/torchmetrics/";
    changelog = "https://github.com/Lightning-AI/torchmetrics/releases/tag/v${version}";
    license = licenses.asl20;
    maintainers = with maintainers; [
      SomeoneSerge
    ];
  };
}
