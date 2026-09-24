// LAW A: the outer is itself a TOP (never instantiated)
module sub (output logic [31:0] q);
  module innermod (output logic [31:0] r);
    assign r = 32'd2;
  endmodule
  assign q = 32'd1;
endmodule
