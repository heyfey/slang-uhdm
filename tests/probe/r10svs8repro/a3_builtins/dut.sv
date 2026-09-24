// r10svs8 ARM a3 -- the OTHER covergroup built-ins.
//
// slang adds them in CoverSymbols.cpp `addBuiltInMethods(*this, true)` on the
// CovergroupBodySymbol -- set_inst_name / get_coverage / get_inst_coverage /
// start / stop -- so they share `sample`'s parent-scope kind
// (SymbolKind::CovergroupBody).  `sample` itself is added separately in
// `CovergroupType::fromSyntax` (`body->addMember(sample.symbol)`), on the SAME
// body.  Every cell here therefore lands in the SAME gate as the witness and
// has to be measured, not assumed.
//
// E1  start()                 void, no args, STATEMENT
// E2  stop()                  void, no args, STATEMENT
// E3  set_inst_name("n8")     void, ONE string arg, STATEMENT
// E4  get_coverage()          REAL return, EXPRESSION position (assignment RHS)
//                             -- and it is MethodFlags::Static in slang
// E5  get_inst_coverage()     REAL return, EXPRESSION position
// E6  get_coverage() as a $display ARG
// E7  ABSTAIN control: a COVERPOINT's get_coverage().  slang calls
//     addBuiltInMethods(*this, false) on CoverpointSymbol too, so the parent
//     scope kind is Coverpoint, NOT CovergroupBody -- it must NOT take the arm.
module a3;

  class cov3;
    int  q8;
    real r8;

    covergroup cgc8;
      cpc8 : coverpoint q8;
    endgroup

    function new();
      cgc8 = new();
    endfunction

    task e1_8();
      cgc8.start();
    endtask

    task e2_8();
      cgc8.stop();
    endtask

    task e3_8();
      cgc8.set_inst_name("n8");
    endtask

    task e4_8();
      r8 = cgc8.get_coverage();
    endtask

    task e5_8();
      r8 = cgc8.get_inst_coverage();
    endtask

    task e6_8();
      $display("cov=%f", cgc8.get_coverage());
    endtask

    task e7_8();
      r8 = cgc8.cpc8.get_coverage();
    endtask
  endclass

endmodule
