# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added

### Changed

### Removed

## [v0.2.0] - 2024-04-13

### Added

- Added the parameters store integration in ECS Task definition
- Saved the secret string in parameter store

### Fixed

### Changed

- Moved to a default Custom image (cillu/nodejs-app:1.0.0)
- Updated the README file

### Removed

## [v0.1.0] - 2024-04-13

### Added

- Output the HTTPS Custom domain URL
- Added module description in README.md
- Added missing comments

### Fixed

### Changed

- Forced HTTPS for both CDN distribution and ALB flows
- Refactoring

### Removed

## [v0.1-beta] - 2024-04-12

### Added

- Added Custom Domains for ALB and CDN
- Added Certificates for Custom Domains

### Fixed


### Changed


### Removed

## [v0.1-alfa] - 2024-04-11

### Added

- Configured VPC and public subnets
- Added Internet Gateway 
- Added Private Subnets and Nat Gateway associations
- Added ECS in Private subnets
- Added ALB in public subnets
- Added vars to enable/disable logging for ALB and Cloudfron
- Added CDN Origin Custom header and configured related ALB rule

### Fixed


### Changed


### Removed

[v0.1.0]: https://github.com/thecillu/devops-aws-tf/compare/v0.1-alfa...v0.1.0
[v0.1-beta]: https://github.com/thecillu/devops-aws-tf/compare/v0.1-alfa...v0.1-beta
[v0.1-alfa]: https://github.com/thecillu/devops-aws-tf/releases/tag/v0.1-alfa
