// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output wire [7:0] o);
  assign #D o = 8'd17;
endmodule
module dut (output logic [7:0] o);
  wire [7:0] a, b;
  sub #(.D(7)) u_a (.o(a));
  sub #(.D(9)) u_b (.o(b));
  assign o = a ^ b;
endmodule
