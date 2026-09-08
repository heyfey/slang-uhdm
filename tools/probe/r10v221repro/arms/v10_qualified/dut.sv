// v10_qualified — the implementer's R2 face, checked for direction.  A
// `::`-QUALIFIED enum reference is a `constant` in golden and a `ref_obj` in
// ours in BOTH holders on BOTH binaries (a FOLD residue that predates this
// law).  Declining its actual must move that cell EXTRA-OURS -> OTHER and
// never SAME -> anything: if it were AWAY, the law would need a fence.
// The instantiated twin is the control.
package v10pkg;
  typedef enum logic [1:0] { Q_A = 2'd0, Q_B = 2'd1, Q_C = 2'd2 } q_e;
endpackage

interface v10_uninst (input logic clk);
  typedef enum logic [2:0] { L_A = 3'd0 } l_e;
  function automatic int f(input int k);
    int acc = 0;
    acc += int'(v10pkg::Q_A);        // :: qualified
    acc += int'(v10pkg::Q_B);
    acc += int'(L_A);                // plain local, the law's own cell
    if (k == int'(v10pkg::Q_C)) acc++;
    return acc;
  endfunction
endinterface

interface v10_inst (input logic clk);
  typedef enum logic [2:0] { L_A = 3'd0 } l_e;
  function automatic int f(input int k);
    int acc = 0;
    acc += int'(v10pkg::Q_A);
    acc += int'(v10pkg::Q_B);
    acc += int'(L_A);
    if (k == int'(v10pkg::Q_C)) acc++;
    return acc;
  endfunction
endinterface

module v10_top (input logic clk);
  v10_inst u_i (.clk(clk));
endmodule
