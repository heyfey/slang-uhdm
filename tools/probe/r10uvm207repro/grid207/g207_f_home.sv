// r10uvm207 arm F — THE HOME MUST-STAY.  The declaring package with NO clone
// anywhere: every member cell must read QUALIFIED on both sides and the two
// binaries' databases must be BYTE-IDENTICAL.
package p207a_f;
  typedef bit [63:0] bt207f;
  typedef struct { bt207f f_min207; bt207f f_max207; int f_stride207; } sf207;
  function automatic int ff207();
    sf207 lf207;
    sf207 af207[];
    return int'(lf207.f_min207) + af207.size();
  endfunction
endpackage

module g207_f_home;
  import p207a_f::*;
  int r207f;
  initial r207f = ff207();
endmodule
