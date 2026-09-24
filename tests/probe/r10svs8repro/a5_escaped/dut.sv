// r10svs8 ARM a5 -- ESCAPED IDENTIFIERS and the USER-`sample` in-law control.
//
// The fix reads SOURCE TEXT (`rawText(expr.sourceRange)` split on the LAST
// '.'), so it IS a name-reading gate and the standing rule requires escaped
// identifiers to be TESTED, not reasoned about.  An escaped identifier may
// CONTAIN a '.', which is exactly the input that breaks a naive split.
//
// G1  ESCAPED covergroup name containing a DOT:  \cg.esc8 .sample();
// G2  ESCAPED covergroup name, no dot:           \escg8 .sample();
// G3  IN-LAW control -- a USER-defined class method actually NAMED `sample`,
//     called on a CLASS handle.  Its parent scope is a ClassType, NOT a
//     CovergroupBody, so it must keep taking the pre-existing arms.
// G4  IN-LAW control -- the same user `sample` called with NO receiver.
module a5;

  class user5;
    int u8;
    function void sample();
      u8 = 1;
    endfunction
  endclass

  class cov5;
    int   q8;
    user5 h5;

    covergroup \cg.esc8 ;
      cpe8 : coverpoint q8;
    endgroup

    covergroup \escg8 ;
      cpf8 : coverpoint q8;
    endgroup

    function new();
      h5 = new();
    endfunction

    task g1_8();
      \cg.esc8 .sample();
    endtask

    task g2_8();
      \escg8 .sample();
    endtask

    task g3_8();
      h5.sample();
    endtask

    function void sample();
      q8 = 9;
    endfunction

    task g4_8();
      sample();
    endtask
  endclass

endmodule
