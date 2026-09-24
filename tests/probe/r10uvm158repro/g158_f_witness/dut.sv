// r10uvm158 grid, arm F — THE REDUCED CORPUS WITNESS.
// `uvm-1.2/src/reg/uvm_reg_predictor.svh:54,117-124` cut down to 24 lines: a
// generic class with `type BUSTYPE=int` whose `get_type_name` holds an if-arm
// `begin` with ONE local of the type parameter and TWO statements, both of
// which slang binds BAD for the DEFAULT binding (`int::type_id` and
// `int.get_type_name()`) and NEITHER of which slang diagnoses, because nothing
// specializes the class.
//
// PRISTINE: uhdm-cmp reports 163 cmp lines and ONE `^LHS:` — the SAME 163 the
// corpus rows report, because a cmp line count is the head object's decompile
// size — with `LHS: begin (…get_name158) 9:27-13:10 / RHS: <null>`.
// PATCHED: 67 lines, one head, on the concat `operation` at 12:20 — the SAME
// next head the corpus rows land on.  MEASUREMENT ONLY.
package p158;
  class base158;
    function new(string name="x"); endfunction
  endclass

  class pred158 #(type BUSTYPE=int) extends base158;
    static string tname158 = "";
    virtual function string get_name158();
      if (tname158 == "") begin
        BUSTYPE t;
        t = BUSTYPE::type_id::create("t");
        tname158 = {"pred158 #(", t.get_type_name(), ")"};
      end
      return tname158;
    endfunction
  endclass
endpackage

module top158;
  initial begin
    $display("hi");
  end
endmodule
