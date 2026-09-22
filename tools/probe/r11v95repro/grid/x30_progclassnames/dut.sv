// v11u93 x30 -- CONTROL, no generate: two BODY classes declared Z then A.
program prg ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
