// § genCaConstRhsWhole433
module top (output [7:0] p);
  for (genvar i = 0; i < 2; i++) begin: g
    assign p[i] = i;
    assign p[i+4] = -i;
  end
endmodule
