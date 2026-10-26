// § genCaConstRhsWhole433
module child #(parameter W = 2) (output [7:0] y);
  logic [W-1:0] x;
  if (W <= 8) begin: g
    assign y = $bits(x) + 1;
  end
endmodule
module top;
  wire [7:0] a, b;
  child #(.W(3)) u1(a);
  child #(.W(5)) u2(b);
endmodule
