// § escIdPpColumnShift146
module top(input logic [3:0] i, output logic [3:0] o);
  wire [3:0] \x+y , \p.q ;
  assign \x+y = i + 4'd1; assign \p.q = \x+y & i; assign o = \p.q ^ \x+y ;
endmodule
