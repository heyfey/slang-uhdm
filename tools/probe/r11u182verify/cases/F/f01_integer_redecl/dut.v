// § splitPortTsKeyOnPortDecl171
module dut (a, b, c, d);
  input  [3:0] a;
  output b;
  output c;
  output d;
  integer b, c;
  reg d;
  always @(*) begin
    b = a;
    c = a + 1;
    d = a[0];
  end
endmodule
