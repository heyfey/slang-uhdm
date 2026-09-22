// LAW A: the ported nested module instantiates a FILE-SCOPE leaf that nothing else uses
module leaf (output logic l); assign l = 1'b0; endmodule
module sub ();
  module innermod (output logic r);
    leaf u_l (.l(r));
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
