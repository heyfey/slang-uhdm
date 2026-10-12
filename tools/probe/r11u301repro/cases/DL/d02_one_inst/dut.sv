// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [7:0] o);
  assign #D o = 8'hA5;
endmodule
module dut (output logic [7:0] o);
  sub #(.D(2)) u_a (.o(o));
endmodule
