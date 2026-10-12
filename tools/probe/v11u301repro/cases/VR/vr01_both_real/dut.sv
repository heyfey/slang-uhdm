// § caTernRealArmKept301
module m #(parameter bit P = 0)();
  logic [7:0] v;
  assign v[7:0] = (P) ? 1.0 : 2.5;
endmodule
module dut;
  m #(.P(1)) u_a();
endmodule
