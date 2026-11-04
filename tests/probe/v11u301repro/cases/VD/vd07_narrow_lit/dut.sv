// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [15:0] o);
  logic [15:0] c;
  assign #D c = 4'd3;
  assign o = c;
endmodule
module dut (output logic [15:0] o);
  logic [15:0] a, b;
  sub #(.D(7)) u_a (.o(a));
  sub #(.D(9)) u_b (.o(b));
  assign o = a ^ b;
endmodule
