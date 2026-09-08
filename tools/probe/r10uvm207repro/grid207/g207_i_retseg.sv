// r10uvm207 arm I — THE RECORDED PRE-EXISTING SEGFAULT, isolated.
//
// A function whose RETURN TYPE is a package STRUCT typedef, cloned into a
// wildcard importer, makes our emitter EXIT 139 in the ELABORATED view at BASE
// `3e4de175` — BEFORE this pass's patch, on the PRISTINE binary.  `verify_golden.py`
// would record such an exit as `SLANG_REJECT` wearing the last stderr warning
// (RESUME.md §9), so it is pinned here as its own arm: the boundary gate asserts
// only that BOTH binaries produce the SAME rc, and the crash itself is this
// pass's recorded residue, not its regression.
package p207a_i;
  typedef bit [63:0] bt207i;
  typedef struct { bt207i i_min207; bt207i i_max207; int i_stride207; } si207;
  function automatic si207 fret207(input si207 fio207);
    si207 lsub207;
    fret207 = lsub207;
    fret207.i_stride207 = int'(fio207.i_min207);
  endfunction
endpackage

package p207b_i;
  import p207a_i::*;
  function automatic int gb207i();
    si207 z207;
    return int'(fret207(z207).i_stride207);
  endfunction
endpackage

module g207_i_retseg;
  import p207b_i::*;
  int r207i;
  initial r207i = gb207i();
endmodule
