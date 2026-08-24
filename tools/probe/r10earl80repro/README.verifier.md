# Verifier record for r10earl80

The adversarial verification of § ovHopOverriddenKeepsValue80 lives in
`tools/probe/r10v80repro/` (README.md there): the two binaries rebuilt and
frozen by the verifier, the five gates re-measured, the heads and canaries,
six independent arms (12,500+ scored cells) covering three-hop chains, varied
intermediate types, gen-for / gen-if / nested generate / interface / program
homes, package parameters, positional overrides, defparam, macro-in-include
defaults, the wider `.sv`+`.v` boundary walks, the nondeterminism
adjudication, and the ranked residues.

VERDICT: ACCEPT WITH FIX.  One delivered-state defect (this directory's
`canaudit.sh` exited 6 because two evidence files spelled the fenced test
names on a `FENCED=` line) was fixed by the verifier in
`/tmp/r10earl80.verified.patch`; no production file was changed.
