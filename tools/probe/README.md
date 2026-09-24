# tools/probe — per-pass evidence

One directory per campaign pass (`<pass>repro/`): its README (the laws it
landed and the residues it left), the grid and verification scripts, the
measurements under `evidence/`, and the grid arms that still judge
NOT_EQUAL against the pinned Surelog (the shapes the exporter does not
model; none occurs in either corpus).

The arms that judge EQUAL were moved to `tests/probe/<same path>` on
2026-09-23 and run as the first stage of `tests/sweep.sh`; a README or
script here that names `<pass>repro/<grid>/<arm>/dut.sv` refers to that
location for those arms.
