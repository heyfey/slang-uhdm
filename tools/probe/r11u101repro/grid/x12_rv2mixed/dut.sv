// LAW A x LAW B: amod's innermod is portless (implicitly instantiated), bmod's is ported
module amod ();
  module innermod ();
    wire [31:0] ra = 32'd1;
  endmodule
endmodule
module bmod ();
  module innermod (output logic rb);
    assign rb = 1'b1;
  endmodule
endmodule
module dut (output logic [31:0] o);
  amod u_a ();
  bmod u_b ();
  assign o = 32'd0;
endmodule
