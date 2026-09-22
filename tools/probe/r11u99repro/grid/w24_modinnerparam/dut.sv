// a nested module WITH a parameter port (slang does NOT implicitly instantiate it)
module sub ();
  module innermod #(parameter int P = 3) ();
    wire [31:0] r = 32'd2;
  endmodule
  wire [31:0] q = 32'd1;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
