// r11u98 g8 -- a PREFIX pair and an underscore: '_'=95 < 'a'=97; "a" < "ab".
module sub ();
  class ab; int b; endclass
  class a; int a; endclass
  class _z; int z; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
