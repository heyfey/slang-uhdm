# r10v130repro/rejarm — arms slang deliberately REJECTS

`v130_b8.sv` names an identifier that is never declared.  slang rejects it (rc=3,
byte-identical stderr on both binaries), Surelog accepts it and mints a wire.
It lives in its OWN directory so the boundary gate's `MODE=dir` run — which
compiles every arm of a directory TOGETHER — does not let one rejecting arm
BOTH-REJECT the whole directory and blind the gate for the arms beside it.
