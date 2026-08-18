// v60 VERIFIER arm B — the DECLARING-SCOPE grid: $unit, interface, a nested
// module, two instances of ONE module, a module inside a generate-if, and a
// function scope.  All take the same package member by explicit scope.
package qp;
  localparam int          QA = 8;
  localparam logic [11:0] QB = 12'h380;
endpackage

// $unit scope
localparam int UNIT_P = qp::QA;

interface s_if ();
  localparam int if_p = qp::QA;
  localparam logic [11:0] if_q = qp::QB;
  logic [if_p-1:0] d;
endinterface

module s_inner ();
  localparam int in_p = qp::QA;
  logic [in_p-1:0] d;
endmodule

module s_outer ();
  localparam int ou_p = qp::QB[3:0];   // part-select: NOT a bare ref
  localparam int ou_q = qp::QA;
  s_inner u_i0 ();
  s_inner u_i1 ();                     // TWO instances of one module
  logic [ou_q-1:0] d;
endmodule

module s_fn ();
  function automatic int f (input int x);
    localparam int fp = qp::QA;        // FUNCTION-scope localparam
    return x + fp;
  endfunction
  localparam int fr = f(1);
  localparam int fu = UNIT_P;          // $unit param ref (NOT a package)
  logic [fr-1:0] d;
endmodule

module s_genif ();
  localparam int gsel = qp::QA;
  if (1) begin : gg
    localparam int gq = qp::QA;        // gen-IF scope
    logic [gq-1:0] d;
  end
endmodule

module a1 ();
  s_outer u_o ();
  s_fn    u_f ();
  s_genif u_g ();
  s_if    u_if ();
endmodule
