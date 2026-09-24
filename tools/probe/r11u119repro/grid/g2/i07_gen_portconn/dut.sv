module c (input logic i, output logic o);
  assign o = i;
endmodule
module top (input logic x, output logic y);
  if (1) begin : g
    c u1(.i(x), .o(n));
    c u2(.i(n), .o(y));
  end
endmodule
