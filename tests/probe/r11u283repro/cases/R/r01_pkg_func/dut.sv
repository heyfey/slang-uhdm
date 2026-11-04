// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
package q;
  function automatic fp::LL mk(); fp::LL l = new(); return l; endfunction
endpackage
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
