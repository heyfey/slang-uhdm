module amod ();
  module innermod (output logic [31:0] ra); assign ra = 32'd1; endmodule
  wire [31:0] w;
  innermod u_i (.ra(w));
endmodule
module bmod ();
  module innermod (input logic [7:0] ib, output logic [7:0] rb); assign rb = ib + 8'd1; endmodule
  wire [7:0] w1, w2;
  innermod u_i (.ib(w1), .rb(w2));
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
