// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
package q;
  import fp::*;
  class K;
    function fp::LL get(); return null; endfunction
    function LL get2(); return null; endfunction
  endclass
endpackage
module dut (output logic [31:0] o);
  q::K k;
  assign o = 32'd0;
endmodule
