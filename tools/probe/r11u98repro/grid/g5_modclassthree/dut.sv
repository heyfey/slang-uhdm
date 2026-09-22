// r11u98 g5 -- three classes declared M, Z, A in a MODULE: is it a full sort?
module sub ();
  class Mclass; int m; endclass
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
