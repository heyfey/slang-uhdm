// v11u90 vx5 -- one definition, TWO elaborated instances.
module sub (output logic [31:0] o);
  wire [31:0] w_plain = 32'd11;
  wire (strong1, weak0) [31:0] w_str = 32'd12;
  assign o = w_plain;
endmodule
module dut (output logic [31:0] o);
  logic [31:0] a, b;
  sub u_a (.o(a));
  sub u_b (.o(b));
  assign o = a ^ b;
endmodule
