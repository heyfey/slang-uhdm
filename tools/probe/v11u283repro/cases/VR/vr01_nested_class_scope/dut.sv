// § scopedClassRetQualSpan283
package fp;
  class OO; class II; int z; endclass endclass
endpackage
class K;
  class N; int y; endclass
endclass
module dut (output logic [31:0] o);
  function automatic K::N mk(); return null; endfunction
  assign o = 32'd0;
endmodule
