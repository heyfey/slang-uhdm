// LAW A: ports AND a parameter port, the param sizes a port and a net
module sub ();
  module innermod #(parameter int W = 4) (input logic [W-1:0] a, output logic [W-1:0] y);
    logic [W-1:0] t;
    assign t = a;
    assign y = t;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
