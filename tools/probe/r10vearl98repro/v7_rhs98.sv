// v98 V7 -- THE Rhs GATE'S FAR EDGES.  Surelog clones only when the Rhs is
// `uhdmoperation`.  Shapes earl98's g3 did not measure: a USER function call,
// a streaming concat, an `inside`, a hierarchical read, an assignment
// pattern, a `$bits()` and a conditional inside a concat.  Every Lhs name is
// shadowed at d1, so the gate is the ONLY thing deciding each row.
module v7leaf98 (input logic clk, input logic [3:0] a, output logic o);
  function automatic logic f98(input logic [3:0] v); return ^v; endfunction
  if (1) begin : gen_b
    logic [3:0] u1, u2;
    logic r_func;    // Rhs = a user func_call
    logic [3:0] r_str;// Rhs = a streaming concat
    logic r_ins;     // Rhs = an `inside`
    logic r_bits;    // Rhs = $bits()
    logic r_hier;    // Rhs = a hierarchical ref
    logic r_cond;    // Rhs = a conditional inside a concat
    assign r_func = f98(u1);
    assign r_str  = {<<{u1}};
    assign r_ins  = u1 inside {u2, 4'h3};
    assign r_bits = $bits(u1) == 4;
    assign r_hier = v7_rhs98.h_top;
    assign r_cond = |{(u1 == u2) ? u1 : u2};
    assign o = r_func ^ r_str[0] ^ r_ins ^ r_bits ^ r_hier ^ r_cond;
    always_ff @(posedge clk) begin u1 <= a; u2 <= u1; end
  end
endmodule
module v7_rhs98 (input logic clk, input logic [3:0] a, output logic o);
  logic r_func, r_ins, r_bits, r_hier, r_cond, h_top;
  logic [3:0] r_str;
  assign h_top = 1'b0;
  v7leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
