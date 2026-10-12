// § caDlyParamLitRhsFresh301
package pk;
  localparam int D = 3;
endpackage
module sub (output logic [7:0] o);
  logic [7:0] c;
  assign #pk::D c = 8'd5;
  assign o = c;
endmodule
module dut (output logic [7:0] o);
  logic [7:0] a, b;
  sub u_a (.o(a));
  sub u_b (.o(b));
  assign o = a ^ b;
endmodule
