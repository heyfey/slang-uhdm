// § scopedClassRetQualSpan283
package fp;
  class LL; int y; endclass
  typedef LL ll_t;
endpackage
module dut (output logic [31:0] o);
  function automatic fp::ll_t mk(); return null; endfunction
  assign o = 32'd0;
endmodule
