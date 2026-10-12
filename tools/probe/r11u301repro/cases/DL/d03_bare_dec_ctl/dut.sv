// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [31:0] o);
  assign #D o = 10;
endmodule
module dut (output logic [31:0] o, p);
  sub u_a (.o(o));
  sub u_b (.o(p));
endmodule
