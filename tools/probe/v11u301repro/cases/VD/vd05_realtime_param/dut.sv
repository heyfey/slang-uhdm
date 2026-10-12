// § caDlyParamLitRhsFresh301
module sub #(parameter realtime D = 1.5) (output logic [7:0] o);
  logic [7:0] c;
  assign #D c = 8'd5;
  assign o = c;
endmodule
module dut (output logic [7:0] o);
  logic [7:0] a, b;
  sub u_a (.o(a));
  sub #(.D(2.5)) u_b (.o(b));
  assign o = a ^ b;
endmodule
