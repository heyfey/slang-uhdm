// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
module dut (output logic [31:0] o);
  function automatic int use_it(fp::LL l); return 0; endfunction
  assign o = 32'd0;
endmodule
