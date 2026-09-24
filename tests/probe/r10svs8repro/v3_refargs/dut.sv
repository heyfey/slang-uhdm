// r10svs8 VERIFIER ARM v3 -- the LAST empty product cell on the ARGS axis.
//
// slang gives get_coverage / get_inst_coverage TWO `ref int` formals with
// DEFAULTS (CoverSymbols.cpp addBuiltInMethods), and get_coverage additionally
// carries MethodFlags::Static.  The implementer's a2 arm only exercises
// `sample`'s formals (value direction, no defaults) and a3 only calls
// get_coverage with NO actuals -- so REF actuals on a covergroup built-in, and
// a STATIC covergroup built-in reached through a type name, are both untested.
//
// X1  get_coverage WITH REF actuals        cgx8.get_coverage(cb8, tb8)
// X2  get_inst_coverage WITH REF actuals   cgx8.get_inst_coverage(cb8, tb8)
// X3  set_inst_name with a REF-ish arg     cgx8.set_inst_name(s8)
// X4  IN-LAW control: a USER method with two ref formals, same actual shape
module v3;

  class cov3v;
    int    q8;
    real   r8;
    int    cb8;
    int    tb8;
    string s8;

    covergroup cgx8;
      cpx8 : coverpoint q8;
    endgroup

    function new();
      cgx8 = new();
    endfunction

    task x1_8();
      r8 = cgx8.get_coverage(cb8, tb8);
    endtask

    task x2_8();
      r8 = cgx8.get_inst_coverage(cb8, tb8);
    endtask

    task x3_8();
      cgx8.set_inst_name(s8);
    endtask

    function void uref8(ref int a8, ref int b8);
      a8 = b8;
    endfunction

    task x4_8();
      this.uref8(cb8, tb8);
    endtask
  endclass

endmodule
