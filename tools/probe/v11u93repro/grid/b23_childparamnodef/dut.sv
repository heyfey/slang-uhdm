module leafp #(parameter int K) (output logic [K-1:0] l); assign l = '1; endmodule
module sub ();
  module innermod (output logic [3:0] r);
    leafp #(.K(4)) u_l (.l(r));
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
