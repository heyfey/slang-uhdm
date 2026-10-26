// § genCaConstRhsWhole433
module top (output [7:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin: g
    logic [i+1:0] q;
    assign y[i] = $bits(q);
  end
endmodule
