// r10uvm65 VERIFIER arm v1_qualdrop.sv - THE EMPTY PRODUCT CELL THE
// IMPLEMENTER'S THREE ARMS NEVER OPENED: the interaction between sec 65's
// `if (!body)` placement and the OTHER rules in emitTaskFuncs that hand this
// point a null body.
//
// TaskFuncEmit.cpp:5213 sets `body = nullptr` OUTRIGHT, before emitStmt is even
// called, when `qualCtor27 || qualLifetime46`:
//
//   sec qualifiedLifetimeMethodLosesNamePortsBody46 - an IN-CLASS method that has
//     BOTH a class-item QUALIFIER (protected/local/static/virtual) AND a WRITTEN
//     LIFETIME (`automatic`/`static` after the `function`/`task` keyword) loses
//     its NAME, its PORTS and its BODY in golden.
//
// sec 65's own comment claims it "can never fire on a body those rules emptied,
// because it is a SYNTAX test (`items` empty), and every dropped body has
// items".  THAT ARGUMENT DOES NOT COVER sec 46: sec 46 drops the body WITHOUT
// LOOKING AT IT.  A qualifier + lifetime + empty body + an end label therefore
// reaches sec 65 with body == nullptr and NOTHING in the sec 65 predicate excludes
// it.  b1/b2/b3 have no such cell: e21/e24/d15 write a lifetime with NO
// qualifier, c04/c16/e23 write a qualifier with NO lifetime.  This arm walks the
// PRODUCT.
//
// Cells q01..q06 are the product; q07..q10 are the controls that isolate which
// factor carries any movement; q11/q12 are the sec 46 cells WITH a body, which say
// what golden does with the routine when the body is not empty.

package v1p;

  class v1c;
    // ---- THE PRODUCT: qualifier AND written lifetime, empty body, end label
    protected function automatic void q01_qual_auto();
    endfunction : q01_qual_auto                              // q01
    protected task automatic q02_qual_auto_port(int a);
    endtask : q02_qual_auto_port                             // q02
    local function automatic void q03_loc_auto();
    endfunction : q03_loc_auto                             // q03
    static task automatic q04_static_auto(int a);
    endtask : q04_static_auto                              // q04
    virtual function automatic void q05_virt_auto();
    endfunction : q05_virt_auto                              // q05
    protected function automatic int q06_qual_auto_ret(int a);
    endfunction : q06_qual_auto_ret                          // q06

    // ---- CONTROLS: exactly one of the two factors
    protected function void q07_qual_only();
    endfunction : q07_qual_only                              // q07 (qual, no lifetime)
    function automatic void q08_life_only();
    endfunction : q08_life_only                              // q08 (lifetime, no qual)
    task automatic q09_life_only_port(int a);
    endtask : q09_life_only_port                             // q09
    protected task q10_qual_only_port(int a);
    endtask : q10_qual_only_port                             // q10

    // ---- sec 46 WITH a body (what golden does when there IS something to lose)
    protected function automatic void q11_qual_auto_body();
      $display("q11");
    endfunction : q11_qual_auto_body                         // q11
    // ---- sec 46 shape but NO end label
    protected function automatic void q12_qual_auto_nolbl();
    endfunction                                              // q12

    // ---- the qualified CONSTRUCTOR (qualCtor27's own null-body path)
    protected function new();
    endfunction : new                                        // q13
  endclass

  // ---- OUT-OF-BODY twin of the sec 46 shape (sec 46 excludes oob, so this must
  // behave like an ordinary OOB definition)
  class v1c2;
    extern protected function void q14_oob_qual_auto();
    extern protected task q15_oob_qual_auto_port(int a);
  endclass
  function void v1c2::q14_oob_qual_auto();
  endfunction : q14_oob_qual_auto                            // q14
  task v1c2::q15_oob_qual_auto_port(int a);
  endtask : q15_oob_qual_auto_port                           // q15

endpackage

// ---- the same product OUTSIDE a class: sec 46 needs classScope, so these are
// pure controls for the lifetime keyword itself.
module v1m;
  function automatic void q16_mod_auto();
  endfunction : q16_mod_auto                                 // q16
  task automatic q17_mod_auto_port(int a);
  endtask : q17_mod_auto_port                                // q17
endmodule
