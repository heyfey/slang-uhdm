// golden grid control for k40: a program instantiated twice, NO nested namesake
program pgm (input logic [3:0] a); int f; initial f = a; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  sub u_s ();
  pgm u_p (.a(x));
  pgm u_q (.a(y));
  assign o = 32'd0;
endmodule
