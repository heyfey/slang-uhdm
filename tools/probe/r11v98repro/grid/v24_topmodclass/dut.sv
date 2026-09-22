// v24 -- the TOP module itself declares Zclass then Aclass.
module dut (output logic [31:0] o);
  class Zclass; int z; endclass
  class Aclass; int a; endclass
  assign o = 32'd0;
endmodule
