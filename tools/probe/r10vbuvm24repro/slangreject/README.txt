gv24d.sv ($past(x,,,clk)) and gv24f.sv (a sequence instance with an empty
slot) are REJECTED by slang, so they produce no database on either binary.
They live in a SUBDIRECTORY so the parent directory still compiles as a
per-directory boundary arm (a rejecting sibling makes the whole dir a
BOTH-REJECT cell and silently costs the positive control).
