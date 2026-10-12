// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 42 : 2.25;
endmodule
module dut;
  m u_a();
endmodule
