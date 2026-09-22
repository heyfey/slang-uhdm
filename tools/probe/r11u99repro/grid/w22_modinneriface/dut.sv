// a nested INTERFACE declaration inside a module
module sub ();
  interface innerif (); wire [31:0] w = 32'd1; endinterface
  wire [31:0] q = 32'd2;
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
