// v11u93 x31 -- CONTROL: the same two classes in a MODULE body.
module sub ();
  class Zclass; int z; endclass
  class Aclass; int a; endclass
endmodule
module dut (output logic [31:0] o);
  sub u_s ();
  assign o = 32'd0;
endmodule
