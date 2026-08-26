// v98 V4b -- A BIND INSTANCE: the bound module's parent is the TARGET
// instance, so the walk must see the TARGET's nets (b_sh) and not a name that
// exists only in the binding module's own file scope.
module v4btgt98 (input logic clk, output logic o);
  logic b_sh;                     // the bind TARGET's own net -> d1 shadow
  assign b_sh = 1'b0;
  assign o = b_sh;
endmodule
module v4bbnd98 (input logic clk);
  if (1) begin : gen_b
    logic [1:0] z1, z2;
    logic b_sh;                   // shadowed by the BIND TARGET's net
    logic b_free;                 // shadowed nowhere
    assign b_sh   = (z1 == z2);
    assign b_free = (z1 != z2);
    always_ff @(posedge clk) begin z1 <= z1 + 1'b1; z2 <= z1; end
  end
endmodule
module v4b_bind98 (input logic clk, output logic o);
  v4btgt98 u_tgt (.clk(clk), .o(o));
  bind v4btgt98 v4bbnd98 u_bnd (.clk(clk));
endmodule
