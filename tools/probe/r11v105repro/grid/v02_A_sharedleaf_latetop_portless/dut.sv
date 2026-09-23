// break: PORTLESS namesake top AFTER dut shares a ported leaf with a LATER top z
module leaf (input logic c, output logic d); assign d = c; endmodule
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod ();
  logic q, r;
  leaf u_m (.c(r), .d(q));
endmodule
module z (input logic e, output logic f);
  leaf u_z (.c(e), .d(f));
endmodule
