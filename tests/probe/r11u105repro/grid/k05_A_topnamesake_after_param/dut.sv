// LAW A: the late top namesake carries a defaulted parameter and a port
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod #(parameter int W = 4) (input logic [W-1:0] a, output logic [W-1:0] b);
  assign b = a;
endmodule
