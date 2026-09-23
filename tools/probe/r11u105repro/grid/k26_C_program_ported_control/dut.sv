// golden grid control for k15/k23: a PORTED uninstantiated program, NO nested namesake
program pgm (input logic [3:0] a); int f; initial f = a; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
