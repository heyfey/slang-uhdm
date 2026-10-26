// § genBodyDefBitsKeepsCall434
module child #(parameter W = 2) (output logic [31:0] y);
  logic [4:0] x;
  if (W > 1) begin : g
    assign y = $bits(x);
  end
endmodule
module top;
  logic [31:0] a, b;
  child #(.W(3)) u1 (.y(a));
  child #(.W(5)) u2 (.y(b));
endmodule
