// v11u90 vy1 -- LAW B, MODULE home, LOCALPARAM name.
module sub (output logic [31:0] o);
  localparam int L = 5;
  logic [31:0] c;
  assign #L c = 32'd10;
  assign o = c;
endmodule
module dut (output logic [31:0] o);
  sub u_s (.o(o));
endmodule
