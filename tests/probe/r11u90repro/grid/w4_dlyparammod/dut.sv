// r11u90 w4 -- LAW B in the MODULE home.
module sub (output logic [31:0] o);
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
