// r10svs7 ARM a1 -- THE WITNESS.  Reproduces third_party/tests/SVSwitch
// Coverage.sv:28-30 in isolation: a class holding an EMBEDDED covergroup whose
// implicit handle is constructed with `new()` inside the class constructor.
//
// ONE STATEMENT PER CONSTRUCTOR, DELIBERATELY.  Measured first (probe
// /tmp/svs7/mp/p3.sv, quoted in the README): Surelog keeps only the LAST
// statement of a class CONSTRUCTOR body (a non-`new` method keeps them all).
// That is a pre-existing, orthogonal Surelog behaviour; putting two cells in one
// constructor would silently delete the first cell and look like a law.
// SVSwitch's own `function new()` has exactly ONE statement, which is why the
// corpus head is unaffected by it.
//
// CELLS
//   C1  cov_paren    -- embedded covergroup, `cg = new();`  (the corpus shape)
//   C2  cov_noparen  -- same, written `cg = new;`
//   C3  cls_paren    -- a CLASS handle `= new()`: the IN-LAW control
//                       (the bound NewClass arm / § invalidNewCallFromSyntax55
//                       territory; must not change shape)
//   C4  cls_noparen  -- class handle `= new;`  (in-law control)
module a1;
  class pkt7;
    int len;
  endclass

  class cov_paren;
    int p;
    covergroup cg1;
      cp1 : coverpoint p;
    endgroup
    function new();
      cg1 = new();          // C1
    endfunction : new
  endclass

  class cov_noparen;
    int p;
    covergroup cg2;
      cp2 : coverpoint p;
    endgroup
    function new();
      cg2 = new;            // C2
    endfunction : new
  endclass

  class cls_paren;
    pkt7 h1;
    function new();
      h1 = new();           // C3
    endfunction : new
  endclass

  class cls_noparen;
    pkt7 h2;
    function new();
      h2 = new;             // C4
    endfunction : new
  endclass
endmodule
