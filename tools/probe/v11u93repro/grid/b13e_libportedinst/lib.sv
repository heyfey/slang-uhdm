module amod ();
  module innermod (output logic [31:0] ra); assign ra = 32'd1; endmodule
  wire [31:0] w;
  innermod u_i (.ra(w));
endmodule
module bmod ();
  wire [7:0] w1;
endmodule
