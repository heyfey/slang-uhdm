interface ifc4 #(parameter int W = 8) ();
  logic [W-1:0] a;
  modport host (output a);
endinterface
module leaf_w7 #(parameter int R = 4)(input logic clk);
  if (1) begin : g
    logic v [R];
    logic [R-1:0] p;
  end
  for (genvar i = 0; i < 2; i++) begin : h
    logic w [R];
  end
endmodule
module top;
  logic clk;
  leaf_w7 #(.R(6)) u (clk);
endmodule
