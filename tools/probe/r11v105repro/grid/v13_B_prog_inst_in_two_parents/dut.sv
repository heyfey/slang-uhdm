// break: program namesake instantiated by dut AND by a second top z (declared later)
program innermod (input logic [3:0] a); int f; initial f = a; endprogram
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  logic [3:0] x;
  sub u_s ();
  innermod u_p (.a(x));
  assign o = 32'd0;
endmodule
module z (input logic [3:0] y);
  innermod u_q (.a(y));
endmodule
