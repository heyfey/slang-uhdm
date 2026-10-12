// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  int ia [2];
  assign ia[0] = (P) ? 1.5 : 2;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
