# Changelog

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## v1.0.0

- Release v1.0.0.
- No breaking changes, but I wanted v1.0.

## [v0.3.0]

- BREAKING: This package now only downloads and returns paths to files, without processing. Similar to Rfam.jl.
- Use new URLs https://www.ebi.ac.uk/interpro/entry/pfam/, https://ftp.ebi.ac.uk/pub/databases/Pfam/.
- Use Preferences to set local directory path and PFAM version.
- Download prints progress in bytes downloaded.
- `alignment_file` function to download individual family alignments.

## [v0.2.3]