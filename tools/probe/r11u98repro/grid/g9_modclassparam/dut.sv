// r11u98 g9 -- a PARAMETERIZED class beside an ordinary one in a MODULE body.
module sub ();
  class Zclass; int z; endclass
  class Pclass #(int N = 1); int p; endclass
  class Aclass; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
