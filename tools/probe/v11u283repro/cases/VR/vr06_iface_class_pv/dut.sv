// § scopedClassRetQualSpan283
package fp;
  class LL; int y; endclass
  interface class IC; pure virtual function fp::LL get(); endclass
  class Impl implements IC; virtual function fp::LL get(); return null; endfunction endclass
endpackage
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
