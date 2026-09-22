// v13 -- byte-order discriminators: '1'=49 < 'B'=66 < '_'=95.
module sub ();
  class A_; int a; endclass
  class AB; int b; endclass
  class A1; int c; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
