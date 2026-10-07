// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
package q;
  class K;
    extern function fp::LL get();
  endclass
  function fp::LL K::get(); return null; endfunction
endpackage
module dut (output logic [31:0] o);
  q::K k;
  assign o = 32'd0;
endmodule
