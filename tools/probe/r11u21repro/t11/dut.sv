// t11 — TAINT PROPAGATION out of a member-read localparam, and the negative
// controls in the same module.
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
  function automatic c_t mk();
    c_t c; c.a = 3; c.b = 32; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module dut #(
    parameter pk::c_t CFG = pk::C
) (output logic o);
  localparam int X  = CFG.a;        // arm A
  localparam int Y  = X + 1;        // reads an arm-A parameter
  localparam int Z  = X;            // BARE read of an arm-A parameter
  localparam int W  = $clog2(Y);    // two hops out
  localparam int P  = 4;            // CONTROL
  localparam int Q  = P + 1;        // CONTROL
  localparam int R  = P;            // CONTROL bare read
  assign o = ^{X[0], Y[0], Z[0], W[0], P[0], Q[0], R[0]};
endmodule
