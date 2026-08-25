// r10uvm141 VERIFIER arm G -- MIXED CLASSES: an affected method sitting NEXT TO
// unaffected siblings in the SAME class (does the suppression leak to the
// sibling?), TWO qualifiers plus a lifetime, and a constructor sharing the class.
package p141g;

  class ga_mix;                    // ONE affected method + THREE unaffected
    int prop;
    function new(int a);           // constructor (ctorNoVars71 already applies)
      int cn = a;
      prop = cn;
    endfunction
    local function automatic int aff(int a);   // AFFECTED
      int ra = a;
      int ra0 = a;
      return ra + ra0;
    endfunction
    function int sib1(int a);                  // sibling: no qualifier, no lifetime
      int rs1 = a;
      return rs1;
    endfunction
    local function int sib2(int a);            // sibling: qualifier only
      int rs2 = a;
      return rs2;
    endfunction
    function automatic int sib3(int a);        // sibling: lifetime only
      int rs3 = a;
      return rs3;
    endfunction
    task sib4(int a);                          // sibling: plain task
      int rs4;
      rs4 = a;
      $display("%0d", rs4);
    endtask
  endclass

  class gb_two;                    // TWO qualifiers + a lifetime
    local static function automatic int q2(int a);
      int rq = a;
      return rq;
    endfunction
  endclass

  class gc_virtprot;               // virtual + protected + lifetime
    virtual protected function automatic int vp(int a);
      int rv = a;
      return rv;
    endfunction
  endclass

endpackage

module t141g;
  initial begin
    p141g::ga_mix h1; p141g::gb_two h2; p141g::gc_virtprot h3;
    h1 = new(1); h2 = new(); h3 = new();
    $display("%0d %0d", h1.sib1(1), h1.sib3(2));
  end
endmodule
