// CONTROL: an ordinary module instance in the outer (a real ref_module)
module leaf (); wire [31:0] w = 32'd1; endmodule
module sub ();
  leaf u_l ();
  class Zouter; int z; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
