// v6_nonsubbody — THE VERIFIER'S OWN HYPOTHESIS.  The patch raises
// `uninstIfaceSubBody218` ONLY around `emitTaskFuncs` (ModuleEmit.cpp:28656-
// 28663), i.e. only inside SUBROUTINE bodies.  But the decoded Surelog fact is
// about writeInterface as a WHOLE: it calls lateBinding NOWHERE, so an enum
// reference in an uninstantiated interface's continuous assign, initial block,
// always block or parameter initialiser should be golden-bare too.  If ours
// binds those, the law is UNDER-APPLIED — a residue, not a regression, but it
// must be measured and named rather than assumed absent.
package v6pkg;
  typedef enum logic [1:0] { N_A = 2'd0, N_B = 2'd1, N_C = 2'd2 } n_e;
endpackage

interface v6_if (input logic clk);
  import v6pkg::*;
  typedef enum logic [2:0] { W_X = 3'd0, W_Y = 3'd1, W_Z = 3'd4 } w_e;

  logic [2:0] a, b, c, d;
  localparam int LP = int'(W_Z);            // parameter initialiser
  logic [2:0] pinit = W_Y;                  // net-decl-assign

  assign a = W_X;                           // continuous assign RHS
  assign b = (c == W_Y) ? W_Z : N_A;        // condition + both ternary arms

  initial begin
    d = N_B;                                // initial-block assignment
    if (d == W_X) d = N_C;                  // initial-block condition
  end

  always_comb begin
    case (a)
      W_X: b = N_A;                         // always case item
      default: b = N_B;
    endcase
  end

  // the SUBROUTINE control in the same holder — this half the law DOES cover
  function automatic w_e sf(input int k);
    if (k == 0) return W_X;
    return W_Z;
  endfunction
endinterface

module v6_top (input logic clk);
endmodule
