// r10uvm207 arm B — THE CONTEXTS.  The same struct member reached from every
// declaration ROLE a clone body has: subroutine-level local, begin-block local,
// for body, foreach body, FORMAL (io_decl), class PROPERTY, and an ARRAY OF the
// struct (the corpus's `.elem.mem` chain).
//
// THE FUNCTION RETURN VARIABLE OF STRUCT TYPE IS **NOT** HERE, and that is a
// measurement, not an omission: at BASE `3e4de175` our emitter SEGFAULTS
// (rc=139) in the ELABORATED view on that one shape.  It is a PRE-EXISTING
// crash, reproduced by `g207_i_retseg.sv` on the pristine binary alone, and it
// is recorded as a residue rather than hidden inside an arm that would then
// measure nothing.
package p207a_c;
  typedef bit [63:0] bt207c;
  typedef struct { bt207c c_min207; bt207c c_max207; int c_stride207; } sr207;

  class C207c;
    sr207 prop207;                        // a class PROPERTY, never a body local
    extern function int m207(input sr207 fio207);
  endclass

  function int C207c::m207(input sr207 fio207);
    sr207 mloc207;
    return int'(fio207.c_min207) + int'(mloc207.c_max207)
         + int'(prop207.c_max207);
  endfunction

  function automatic int fctx207(input sr207 fio207);
    sr207 lsub207;                        // subroutine level
    sr207 larr207[];                      // ARRAY OF the struct: .elem.mem
    int   acc207;
    acc207 = int'(lsub207.c_min207);
    begin : blk207
      sr207 lblk207;                      // block local
      acc207 += int'(lblk207.c_min207);
    end
    for (int i207 = 0; i207 < 2; i207++) begin
      sr207 lfor207;                      // for-body local
      acc207 += int'(lfor207.c_max207);
    end
    foreach (larr207[j207]) acc207 += int'(larr207[j207].c_min207);
    return acc207 + int'(fio207.c_min207);
  endfunction
endpackage

package p207b_c;
  import p207a_c::*;
  function automatic int gb207c();
    sr207 z207;
    C207c c207;
    c207 = new();
    return fctx207(z207) + c207.m207(z207);
  endfunction
endpackage

module g207_b_ctx;
  import p207b_c::*;
  int r207c;
  initial r207c = gb207c();
endmodule
