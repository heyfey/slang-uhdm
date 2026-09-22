module sub ();
  module innermod (output logic [31:0] r);
    assign r = 32'd2;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
