// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
`define RT fp::LL
module dut (output logic [31:0] o);
  function automatic `RT mk(); return null; endfunction
  assign o = 32'd0;
endmodule
