// r10v75 arm a6 -- a PROGRAM block's gen scope, and a gen scope in a module
// instantiated INSIDE another gen scope (two instance levels), and a gen-scope
// always inside an instance whose parameter is OVERRIDDEN per instance.
package a6p;
  parameter int NB = 4;
endpackage

program a6prog (input logic clk);
  import a6p::*;
  logic [31:0] x, y, z;
  if (1) begin : gen_p
    initial x = {NB{1'b1}};          // A6_P1 gen scope in a PROGRAM (initial)
  end
  initial y = {NB{1'b1}};            // A6_P2 program body (control)
  assign z = {NB{1'b1}};             // A6_P2b program body cont_assign
endprogram

module a6inner #(parameter int Q = 1) (input logic clk, output logic [31:0] o);
  import a6p::*;
  logic [31:0] r0;
  if (Q > 0) begin : gen_in
    always_comb r0 = {NB{1'b1}} + Q; // A6_P3 gen scope, two instance levels
  end
  assign o = r0;
endmodule

module a6outer (input logic clk, output logic [31:0] o);
  logic [31:0] t0, t1;
  for (genvar g = 0; g < 2; g++) begin : gen_out
    a6inner #(g + 1) u_in (.clk(clk), .o(t0));
  end
  a6inner #(3) u_flat (.clk(clk), .o(t1));
  assign o = t0 ^ t1;
endmodule

module a6top (input logic clk, output logic [31:0] o);
  a6prog  u_p (.clk(clk));
  a6outer u_o (.clk(clk), .o(o));
endmodule
