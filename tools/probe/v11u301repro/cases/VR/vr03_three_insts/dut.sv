// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 3.25 : 42;
endmodule
module dut;
  m #(.P(1)) u_a();
  m #(.P(0)) u_b();
  m #(.P(1)) u_c();
endmodule
