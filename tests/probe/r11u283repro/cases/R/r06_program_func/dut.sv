// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 1; endclass
  class PP #(int W = 4); int y; endclass
  typedef LL ll_t;
endpackage
program prg;
  function automatic fp::LL mk(); return null; endfunction
endprogram
module dut (output logic [31:0] o);
  prg u ();
  assign o = 32'd0;
endmodule
