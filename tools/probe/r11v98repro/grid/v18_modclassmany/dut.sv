// v18 -- five classes, mixed case and digits, all out of byte order.
module sub ();
  class zz; int a; endclass
  class Zz; int b; endclass
  class z1; int c; endclass
  class Az; int d; endclass
  class aZ; int e; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
