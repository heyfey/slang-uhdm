// r10uvm207 arm C — THE SHARING CONTROL, the corpus's decisive question.  The
// SAME package struct typedef is declared by a HOME body local AND by the body
// the importer clones, so the two producers can be compared on whether golden
// SPLITS the struct typespec per declaration while keeping the home's member
// alias QUALIFIED.
package p207a_h;
  typedef bit [63:0] bt207h;
  typedef struct { bt207h h_min207; bt207h h_max207; int h_stride207; } sh207;

  function automatic int fhome207();
    sh207 lhome207;                       // a HOME body local: MUST STAY QUAL
    return int'(lhome207.h_min207);
  endfunction

  function automatic int fboth207();
    sh207 lboth207;                       // reached from the clone as well
    return int'(lboth207.h_max207);
  endfunction
endpackage

package p207b_h;
  import p207a_h::*;
  function automatic int gb207h();
    return fboth207() + fhome207();
  endfunction
endpackage

module g207_c_share;
  import p207b_h::*;
  int r207h;
  initial r207h = gb207h();
endmodule
