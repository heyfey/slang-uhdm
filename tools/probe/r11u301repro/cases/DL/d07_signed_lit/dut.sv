// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic signed [7:0] o);
  assign #D o = 8'sd3;
endmodule
module dut (output logic signed [7:0] o, p);
  sub u_a (.o(o));
  sub u_b (.o(p));
endmodule
