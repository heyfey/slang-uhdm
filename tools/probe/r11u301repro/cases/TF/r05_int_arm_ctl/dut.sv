// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 1.5 : 42;
endmodule
module dut;
  m #(.P(0)) u_a();
endmodule
