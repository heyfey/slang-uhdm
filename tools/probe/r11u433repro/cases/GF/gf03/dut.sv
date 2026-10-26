// § genCaConstRhsWhole433
module top (output [3:0] y);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = $bits(x) > i;
  end
endmodule
