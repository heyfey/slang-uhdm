# tools/probe — per-pass evidence

One directory per campaign pass (`<pass>repro/`): its README (the laws it
landed and the residues it left), the grid and verification scripts, the
measurements under `evidence/`, and the grid cases that still judge
NOT_EQUAL against the pinned Surelog (the shapes the exporter does not
model; none occurs in either corpus).

The cases that judge EQUAL were moved to `tests/probe/<same path>` on
2026-09-23, and every case that judged EQUAL or STRICT_NOTEQUAL on
2026-11-04 (27856 of 40722; the NOT_EQUAL, SLANG_FAIL and SURELOG_FAIL
cases and the duplicates stay) followed them; they run as the first stage
of `tests/sweep.sh`. A test exists in one place: a README or script here, or
a comment in the exporter source, that names `<pass>repro/<grid>` names the
grid's home (its README, measurements and residue cases stay here), and a
case that moved is found by the same path under `tests/probe/`; a source
comment names `tests/probe/<pass>repro/...` where every case it cites moved.
