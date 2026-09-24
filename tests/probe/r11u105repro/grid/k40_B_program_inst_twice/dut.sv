// LAW B: the program namesake is instantiated twice
program innermod (input logic [3:0] a); int f; initial f = a; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] x, y;
  sub u_s ();
  innermod u_p (.a(x));
  innermod u_q (.a(y));
  assign o = 32'd0;
endmodule
