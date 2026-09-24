module leaf #(parameter int K = 1) (output logic [K-1:0] l); assign l = '0; endmodule
module sub ();
  module innermod (output logic [7:0] r);
    leaf #(.K(8)) u_l (.l(r));
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  wire [1:0] w;
  sub u_s ();
  leaf #(.K(2)) u_l2 (.l(w));
  assign o = {30'd0, w};
endmodule
