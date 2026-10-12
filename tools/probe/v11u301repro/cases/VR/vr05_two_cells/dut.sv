// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  logic [7:0] arr[2];
  assign arr[0] = (P) ? 1.5 : 4;
  assign arr[1] = (P) ? 6 : 2.5;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
