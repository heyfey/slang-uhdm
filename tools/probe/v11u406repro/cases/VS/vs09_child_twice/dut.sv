// § arrElemVarKind406
module child #(parameter N = 2);
  string s [N];
  real r [N];
endmodule
module top;
  child #(2) c1();
  child #(3) c2();
endmodule
