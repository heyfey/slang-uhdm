// § defNetVarNoSlot130v
module sub;
  var enum {T0, T1, T2} tt;
  initial tt = T1;
endmodule
module top;
  sub u1();
endmodule
