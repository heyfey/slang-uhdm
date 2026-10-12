// § caDlyParamLitRhsFresh301
module sub #(parameter int E = 1) (output logic [7:0] o);
  localparam int D = E + 1;
  assign #D o = 8'd3;
endmodule
module dut (output logic [7:0] o, p);
  sub u_a (.o(o));
  sub #(.E(3)) u_b (.o(p));
endmodule
