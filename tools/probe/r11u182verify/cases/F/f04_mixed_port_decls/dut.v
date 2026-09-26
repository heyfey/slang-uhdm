// § splitPortTsKeyOnPortDecl171
module dut (i, x, y, z);
  input [1:0] i;
  output x;
  output y, z;
  reg x, y, z;
  always @(*) begin
    x = i[0];
    y = i[1];
    z = ^i;
  end
endmodule
