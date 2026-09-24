// break: namesake top AFTER dut holds its OWN nested module (innermod::deep)
module sub ();
  module innermod (); wire [7:0] n = 8'd1; endmodule
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
module innermod (input logic [3:0] a, output logic [3:0] b);
  module deep (input logic x, output logic y); assign y = ~x; endmodule
  logic q;
  deep u_d (.x(a[0]), .y(q));
  assign b = {3'b0, q};
endmodule
