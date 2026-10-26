// § genCaConstRhsWhole433
module top (output [15:0] y);
  for (genvar i = 0; i < 2; i++) begin: g
    logic [3:0] q;
    assign y[i*8 +: 8] = $bits(q);
  end
endmodule
