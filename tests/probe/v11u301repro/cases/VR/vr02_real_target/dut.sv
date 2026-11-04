// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  real ra [2];
  assign ra[0] = (P) ? 1.5 : 2.5;
endmodule
module dut;
  m #(.P(0)) u_a();
endmodule
