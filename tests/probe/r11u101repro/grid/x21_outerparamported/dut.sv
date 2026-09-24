// LAW A: an outer PARAMETERIZED and instantiated with two values; nested ported module
module sub #(parameter int K = 1) ();
  module innermod (output logic [31:0] r);
    assign r = 32'd2;
  endmodule
  wire [31:0] q = K;
endmodule
module dut (output logic [31:0] o);
  sub #(.K(2)) u_s1 ();
  sub #(.K(5)) u_s2 ();
  assign o = 32'd0;
endmodule
