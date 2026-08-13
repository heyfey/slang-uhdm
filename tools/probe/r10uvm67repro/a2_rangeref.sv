// r10uvm67 arm a2 — THE HEAD'S ACTUAL SHAPE, read off the cmp RHS and not the
// brief: a `ref_obj` used as a RANGE BOUND in a package FUNCTION's return type,
// naming a package PARAMETER, and whether it carries `vpiActual`.
//
// The witness, uvm-1.2 src/base/uvm_globals.svh:
//
//   407  parameter UVM_LINE_WIDTH   = `UVM_LINE_WIDTH;              // 120
//   408  parameter UVM_NUM_LINES    = `UVM_NUM_LINES;               // 120
//   409  parameter UVM_SMALL_STRING = UVM_LINE_WIDTH*8-1;           //    959
//   410  parameter UVM_LARGE_STRING = UVM_LINE_WIDTH*UVM_NUM_LINES*8-1;  // 115199
//   ...
//   421  function bit[UVM_LARGE_STRING:0] uvm_string_to_bits(string str);
//   434  function string uvm_bits_to_string(logic [UVM_LARGE_STRING:0] str);
//
// GOLDEN gives the 421/434 range-bound `ref_obj (UVM_LARGE_STRING)` a
// `vpiActual` pointing at the PARAMETER'S OWN Rhs object — the FOLDED
// `constant` (INT:115199, size 32, vpiConstType 7) in the value-carrying view
// and the UNFOLDED `operation` in the declaration view.  WE leave `vpiActual`
// NULL in exactly the views whose ref_obj carries the function-qualified
// fullname, which is what `SafeCompare(constant, nullptr)` reports as
// `LHS: constant@410:30 ... RHS: <null>`.
//
// Axes, one per group:
//   A  WHERE the range-bound reference sits (return type / argument / local)
//   B  WHAT it names (same-package param, imported param, localparam, literal)
//   C  the parameter's INITIALIZER (folded expression vs plain literal)
//   D  the scope of the subroutine (package function / class method / module)

package a2pkg;

  parameter A2_LINE_WIDTH = 120;
  parameter A2_NUM_LINES  = 120;
  parameter A2_SMALL = A2_LINE_WIDTH*8-1;                    // folded, 959
  parameter A2_LARGE = A2_LINE_WIDTH*A2_NUM_LINES*8-1;       // folded, 115199
  parameter A2_LIT   = 115199;                               // literal twin
  localparam A2_LOCAL = A2_LINE_WIDTH*8-1;                   // localparam twin
  parameter int A2_TYPED = A2_LINE_WIDTH*8-1;                // typed twin

  // m01 — THE WITNESS: package function, RETURN TYPE range bound, folded param
  function bit[A2_LARGE:0] a2_to_bits(string str);
    a2_to_bits = 0;
  endfunction

  // m02 — the same, ARGUMENT type range bound
  function string a2_from_bits(logic [A2_LARGE:0] str);
    a2_from_bits = "";
  endfunction

  // m03 — LITERAL-initialised parameter as the bound
  function bit[A2_LIT:0] a2_lit_bits(string str);
    a2_lit_bits = 0;
  endfunction

  // m04 — LOCALPARAM as the bound
  function bit[A2_LOCAL:0] a2_local_bits(string str);
    a2_local_bits = 0;
  endfunction

  // m05 — TYPED parameter as the bound
  function bit[A2_TYPED:0] a2_typed_bits(string str);
    a2_typed_bits = 0;
  endfunction

  // m06 — a LOCAL VARIABLE's type range bound inside the body
  function int a2_local_var(int x);
    bit [A2_LARGE:0] tmp;
    tmp = x;
    a2_local_var = tmp[0];
  endfunction

  // m07 — a plain LITERAL bound (control: no ref_obj at all)
  function bit[959:0] a2_plain_bits(string str);
    a2_plain_bits = 0;
  endfunction

  // m08 — an EXPRESSION over the parameter as the bound
  function bit[A2_LARGE-1:0] a2_expr_bits(string str);
    a2_expr_bits = 0;
  endfunction

  // m09 — a package-scope VARIABLE with the same range (not a subroutine)
  bit [A2_LARGE:0] a2_pkg_var;

  // m10 — a class METHOD's return type range bound
  class a2cls;
    function bit[A2_LARGE:0] m_to_bits(string str);
      m_to_bits = 0;
    endfunction
    bit [A2_LARGE:0] m_prop;
  endclass

  // m11 — a package TYPEDEF with the same range
  typedef bit [A2_LARGE:0] a2_bits_t;

endpackage : a2pkg

// m12 — a MODULE-scope function whose bound names an IMPORTED package param,
//       with the import at COMPILATION-UNIT scope (the SimpleUVM spelling:
//       `import uvm_pkg::*;` on line 1 of testbench.sv, outside every module).
import a2pkg::*;

module a2top;
  function bit[A2_LARGE:0] t_to_bits(string str);
    t_to_bits = 0;
  endfunction
  bit [A2_LARGE:0] t_var;
  initial $display("%0d", A2_LARGE);
endmodule
