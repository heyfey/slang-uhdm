// r11u98 g6 -- BYTE order vs case-insensitive order: 'A'=65 'Z'=90 'b'=98.
module sub ();
  class b_cls; int b; endclass
  class Z_cls; int z; endclass
  class A_cls; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
