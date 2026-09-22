// r11u98 g1 -- x30 re-run: a PROGRAM body declares Zclass then Aclass, no generate.
program prg ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endprogram
module dut (output logic [31:0] o);
  prg u_p ();
  assign o = 32'd0;
endmodule
