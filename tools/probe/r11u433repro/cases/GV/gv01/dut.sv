// § genCaConstRhsWhole433
module top (output [3:0] y, output [15:0] p, output [31:0] z);
  logic [4:0] x;
  for (genvar i = 0; i < 2; i++) begin: g
    assign y[i] = $bits(x) > i;
    assign p[i*8 +: 8] = i + 1;
  end
endmodule
