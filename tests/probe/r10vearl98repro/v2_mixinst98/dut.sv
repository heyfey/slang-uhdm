// v98 V2 -- THE INSTANCE-SHARING TRAP.  THREE instances of ONE definition;
// only the middle one has an ancestor declaring the shadowing name.  slang
// caches InstanceBodySymbol per parameterization, so if the patch reads
// `body.parentInstance` on a SHARED body it must answer the SAME for all
// three -- which would be wrong for two of them.  Earlgrey is this shape
// (4 of 128 prim_fifo_sync unbind).
module v2leaf98 (input logic clk, input logic [1:0] a, output logic o);
  if (1) begin : gen_b
    logic [1:0] q1, q2;
    logic m_sh;      // shadowed ONLY under u_wrapB
    assign m_sh = (q1 == q2);
    assign o = m_sh;
    always_ff @(posedge clk) begin q1 <= a; q2 <= q1; end
  end
endmodule
module v2wrapA98 (input logic clk, input logic [1:0] a, output logic o);
  v2leaf98 u_leaf (.clk(clk), .a(a), .o(o));       // NO m_sh above
endmodule
module v2wrapB98 (input logic clk, input logic [1:0] a, output logic o);
  logic m_sh;                                       // the shadow
  assign m_sh = 1'b0;
  v2leaf98 u_leaf (.clk(clk), .a(a), .o(o));
endmodule
module v2wrapC98 (input logic clk, input logic [1:0] a, output logic o);
  v2leaf98 u_leaf (.clk(clk), .a(a), .o(o));       // NO m_sh above
endmodule
module v2_mixinst98 (input logic clk, input logic [1:0] a, output logic [2:0] o);
  v2wrapA98 u_a (.clk(clk), .a(a), .o(o[0]));
  v2wrapB98 u_b (.clk(clk), .a(a), .o(o[1]));
  v2wrapC98 u_c (.clk(clk), .a(a), .o(o[2]));
endmodule
