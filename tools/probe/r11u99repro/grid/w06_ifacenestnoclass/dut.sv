// CONTROL: non-simple interface, NO class at all
interface inner (); wire [31:0] w = 32'd1; endinterface
interface outer ();
  inner u_in ();
  wire [31:0] q = 32'd2;
endinterface
module dut (output logic [31:0] o);
  outer u_o ();
  assign o = 32'd0;
endmodule
