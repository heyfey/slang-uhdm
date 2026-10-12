// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [7:0] o);
  logic [7:0] c;
  assign #D c = 8'hAB;
  assign o = c;
endmodule
module dut (output logic [7:0] o);
  logic [7:0] a, b, d;
  sub #(.D(7)) u_a (.o(a));
  sub u_b (.o(b));
  sub #(.D(2)) u_c (.o(d));
  assign o = a ^ b ^ d;
endmodule
