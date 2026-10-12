// § caTernRealArmKept301
module m #(parameter int W = 4)();
  logic [7:0] arr[2];
  assign arr[0] = (W > 2) ? 0.5 : 9;
endmodule
module dut;
  m #(.W(8)) u_a();
endmodule
