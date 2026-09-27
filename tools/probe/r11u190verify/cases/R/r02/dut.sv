// § splitPortIntRedeclLogicTs180 (r11u190: shortint, longint and int unsigned redeclarations, and a signed port declaration redeclared int)
module dut(a, s, l, u, sg);
  input [3:0] a;
  output s;
  output l;
  output u;
  output signed sg;
  shortint s;
  longint l;
  int unsigned u;
  int sg;
  always_comb begin
    s = a;
    l = a;
    u = a;
    sg = a;
  end
endmodule
