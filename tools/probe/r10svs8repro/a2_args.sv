// r10svs8 ARM a2 -- ARGUMENTS on the built-in `sample`.
//
// `covergroup c with function sample(...)` gives the built-in `sample` FORMALS
// (slang: CoverSymbols.cpp `sample.copyArg(*arg)` for every
// VariableFlags::CoverageSampleFormal), so the call site writes actuals.
//
// D1  one LITERAL actual      cga8.sample(3);
// D2  one REF actual          cga8.sample(w8);
// D3  TWO actuals             cgb8.sample(3, w8);
// D4  an EXPRESSION actual    cgb8.sample(w8 + 1, 7);
// D5  IN-LAW control          a USER method with the same actual shapes.
module a2;

  class cov2;
    int q8;
    int w8;

    covergroup cga8 with function sample(int x8);
      cpa8 : coverpoint q8;
    endgroup

    covergroup cgb8 with function sample(int x8, int y8);
      cpb8 : coverpoint q8;
    endgroup

    function new();
      cga8 = new();
    endfunction

    task d1_8();
      cga8.sample(3);
    endtask

    task d2_8();
      cga8.sample(w8);
    endtask

    task d3_8();
      cgb8.sample(3, w8);
    endtask

    task d4_8();
      cgb8.sample(w8 + 1, 7);
    endtask

    function void user8(int x8, int y8);
      q8 = x8 + y8;
    endfunction

    task d5_8();
      this.user8(3, w8);
    endtask
  endclass

endmodule
