// § caTernRealArmKept301
module m #(parameter bit P = 0)(output logic [7:0] v);
  assign v[7:4] = (P) ? 1.5 : 4'd2;
  assign v[3:0] = 4'd0;
endmodule
module dut (output logic [7:0] v);
  m #(.P(1)) u_a(.v(v));
endmodule
