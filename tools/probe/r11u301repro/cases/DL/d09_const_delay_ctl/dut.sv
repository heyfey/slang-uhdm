// § caDlyParamLitRhsFresh301
module sub (output logic [7:0] o);
  assign #3 o = 8'd3;
endmodule
module dut (output logic [7:0] o, p);
  sub u_a (.o(o));
  sub u_b (.o(p));
endmodule
