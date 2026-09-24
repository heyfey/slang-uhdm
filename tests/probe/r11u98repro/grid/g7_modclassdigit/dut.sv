// r11u98 g7 -- LEXICOGRAPHIC vs NATURAL: byte order is c10, c2, c9.
module sub ();
  class c9; int a; endclass
  class c10; int b; endclass
  class c2; int c; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
