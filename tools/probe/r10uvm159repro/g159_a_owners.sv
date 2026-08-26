// r10uvm159 GRID A — OWNER positions of a folded read of a parameter that the
// enclosing PACKAGE materialized from `import uvm_pkg::*`, inside a CLASS
// method.  Every row is a different vpi OWNER of the folded constant; the
// qualified read and the package's own (non-imported) parameters are the
// negative controls.  MEASUREMENT ONLY.
package p159a_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  parameter int PK159T = 5;
  parameter     PK159U = 6;

  class c159a extends uvm_object;
    `uvm_object_utils(c159a)

    int          q159;
    int          r159;
    logic [31:0] v159;
    string       s159;

    function new(string name = "c159a");
      super.new(name);
    endfunction

    // A_OP_INSIDE : operation operand (the corpus head's own shape)
    function void a_op_inside();
      if (q159 inside {UVM_SETINT, UVM_SETSTR, UVM_SETOBJ}) r159 = 1;
    endfunction
    // A_OP_ARITH : operation operand, arithmetic
    function void a_op_arith();
      r159 = UVM_SETINT + 1;
    endfunction
    // A_OP_CONCAT : concat member
    function void a_op_concat();
      r159 = {UVM_SETINT};
    endfunction
    // A_OP_REPL : replication count
    function void a_op_repl();
      v159 = {UVM_SETINT{1'b0}};
    endfunction
    // A_OP_COND : ternary arms and condition
    function void a_op_cond();
      r159 = (q159 == UVM_SETINT) ? UVM_SETSTR : UVM_SETOBJ;
    endfunction
    // A_PLAIN : assignment RHS with NO operation between
    function void a_plain();
      r159 = UVM_SETINT;
    endfunction
    // A_RET : return_stmt owner
    function int a_ret();
      return UVM_SETINT;
    endfunction
    // A_ARG : subroutine-call argument
    function void a_arg();
      s159 = $sformatf("%0d", UVM_SETINT);
    endfunction
    // A_SEL : bit-select index through an operation
    function void a_sel();
      r159 = v159[UVM_SETINT % 32];
    endfunction
    // A_CASE : case item
    function void a_case();
      case (q159)
        UVM_SETINT: r159 = 1;
        default:    r159 = 0;
      endcase
    endfunction
    // A_QUAL : QUALIFIED read — Surelog's paPackage_scope arm attaches no ts
    function void a_qual();
      r159 = uvm_pkg::UVM_SETINT + 1;
    endfunction
    // A_OWN_T / A_OWN_U : the package's OWN parameters, not imports
    function void a_own();
      r159 = PK159T + 1;
      r159 = PK159U + 1;
    endfunction
  endclass
endpackage

module m159a;
  import p159a_pkg::*;
  c159a h159;
  initial begin
    h159 = new("h159");
    h159.a_op_inside();
  end
endmodule
