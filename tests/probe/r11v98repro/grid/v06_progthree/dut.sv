// v06 -- a PROGRAM body with three classes M, Z, A.
program prg ();
  class Mclass; int m; endclass
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
