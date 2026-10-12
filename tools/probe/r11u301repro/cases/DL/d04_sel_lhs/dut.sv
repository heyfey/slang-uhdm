// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [7:0] o);
  assign #D o[3:0] = 4'd1;
  assign o[7:4] = 4'd0;
endmodule
module dut (output logic [7:0] o, p);
  sub u_a (.o(o));
  sub u_b (.o(p));
endmodule
