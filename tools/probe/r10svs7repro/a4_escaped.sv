// r10svs7 ARM a4 -- THE ESCAPED-IDENTIFIER TEST.
//
// The standing method law says: test ESCAPED identifiers on any name-reading
// gate.  § covergroupNewCall7's EMIT half reads no name at all (its gate is the
// expression KIND and the emitted `vpiName` is the literal string "new"), but
// its Lhs half hands the Lhs ref's OWN name to the artefact `hier_path`
// (`hp->VpiName(((UHDM::ref_obj*)lhs)->VpiName())`, § invalidNewCallFromSyntax55's
// line, now reached by covergroup handles too).  That IS a name-carrying path,
// so it is tested rather than reasoned about.
//
// CELLS
//   F1  \esc_cg7  -- an ESCAPED covergroup name constructed with `new()`
//   F2  \esc_h7   -- an ESCAPED CLASS-handle name constructed with `new()`,
//                    the in-law control for the same line
module a4;
  class pkt4;
    int len;
  endclass

  class esc_cov;
    int p;
    covergroup \esc_cg7 ;
      cpf1 : coverpoint p;
    endgroup
    function new();
      \esc_cg7  = new();          // F1
    endfunction : new
  endclass

  class esc_cls;
    pkt4 \esc_h7 ;
    function new();
      \esc_h7  = new();           // F2 -- IN-LAW control
    endfunction : new
  endclass
endmodule
