// § splitPortIntRedeclLogicTs180 § procLvPartSelBoundCallName181v (r11u190 cross: integer-redeclared ports written under part selects with call bounds)
module dut(a, b, c);
  input [3:0] a;
  output b;
  output c;
  integer b;
  integer c;
  function automatic int f(int x); return x; endfunction
  always @(*) begin
    b = 0;
    b[f(3):f(0)] = a;
    c = 0;
    c[f(7):f(4)] = a;
    c[3:0] = ~a;
  end
endmodule
