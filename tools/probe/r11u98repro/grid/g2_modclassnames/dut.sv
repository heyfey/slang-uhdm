// r11u98 g2 -- x31 re-run: a MODULE body declares Zclass then Aclass, no generate.
module sub ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
