## [1.2.4](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.2.3...v1.2.4) (2021-10-20)


### Bug Fixes

* Changed to slack web hook URL ([89f2d7d](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/89f2d7d5a0e42421741a94a29a20a7e6f475198e))

## [1.2.3](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.2.2...v1.2.3) (2021-10-15)


### Bug Fixes

* Removed the e5 factor from scale.go ([f054e3f](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/f054e3f4e008cf5913ee6e2da0f7d3b3d480f099))

## [1.2.2](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.2.1...v1.2.2) (2021-10-14)


### Bug Fixes

* Removed the alarms other than scaling from the module ([08e5626](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/08e5626204927a27e041319556e8fca52b0c4b69))

## [1.2.1](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.2.0...v1.2.1) (2021-10-13)


### Bug Fixes

* Corrected the readme file ([da02913](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/da0291349b989c27d05318142b922fad09fffc13))

# [1.2.0](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.1.1...v1.2.0) (2021-10-13)


### Features

* Enabled the cool down period to avoid frequent scaling actions ([ced3a45](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/ced3a45013f8a4cf8f9c3607469d8a32ed9094cd))

## [1.1.1](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.1.0...v1.1.1) (2021-09-27)


### Bug Fixes

* Updated the changelog.md to reflect right features and fixes ([91b2c42](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/91b2c42f1118a9afae88318152e1f76749fc040f))

# [1.1.0](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.0.1...v1.1.0) (2021-09-27)


### Bug Fixes

* Modularised simple and scaling kinesis to avoid unnecessary creation of aws services ([89e7f58](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/89e7f58dc243e6a59653e4789a17f270bb0b4c8b))
* removed the hardcode value for scaling period to accept as a parameter ([8c6028c](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/8c6028ccc6d6c69ab096e196cf0eac3bb5b2f9c6))
* Removed the simple kinesis stream - the module is only for kinesis autoscaling ([bb8bb54](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/bb8bb54d24eb0c867eabdee8e030f697734d8811))

### Features

*  Accept additional alarm actions in lambda function to update the alarm metric accordingly ([00e9c53](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/00e9c536006f849c5347578f285ed03ae99e3586))
*  The implementation of the minimum shard count for scale down. ([54fba2b](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/54fba2b7b3632ed06e82b5ec2ee5d7fe65622a04))

## [1.0.1](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/compare/v1.0.0...v1.0.1) (2021-09-20)


### Bug Fixes

* Updated the git hub repo ([16ebc1d](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/16ebc1d040973d27e4aef3ab67494a688c359eed))

# 1.0.0 (2021-09-20)


### Features

* Updated the branch with main ([4818806](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/48188066306accfcbaa36b01ec6ff9509794d94c))
* Updated the branch with main ([984afe5](http://bitbucket.org/adaptavistlabs/module-kinesis-stream/commits/984afe5c9aab92a641fd5baee1d0d98d42603a1c))
