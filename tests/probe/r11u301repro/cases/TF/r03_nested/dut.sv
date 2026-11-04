// § caTernRealArmKept301
module m #(parameter int P = 0)();
  logic [7:0] arr[2];
  assign arr[1] = (P == 0) ? ((P == 1) ? 3 : 0.5) : 7;
endmodule
module dut;
  m u_a();
endmodule
