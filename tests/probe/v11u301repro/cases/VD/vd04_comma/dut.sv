// § caDlyParamLitRhsFresh301
module sub #(parameter int D = 4) (output logic [7:0] o);
  logic [7:0] c, e;
  assign #D c = 8'd1, e = 8'd2;
  assign o = c ^ e;
endmodule
module dut (output logic [7:0] o);
  logic [7:0] a, b;
  sub #(.D(7)) u_a (.o(a));
  sub #(.D(9)) u_b (.o(b));
  assign o = a ^ b;
endmodule
