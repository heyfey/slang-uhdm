// A HIERARCHICAL reference inside the operation Rhs.
module ch(input logic [31:0] i, output logic [31:0] x);
  assign x = i;
endmodule
module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  ch u1(.i(a), .x());
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = u1.x | src;
  end
  assign o = mv;
endmodule
