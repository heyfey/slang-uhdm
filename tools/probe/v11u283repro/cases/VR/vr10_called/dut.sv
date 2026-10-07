// § scopedClassRetQualSpan283
package fp;
  class LL; int y = 3; endclass
endpackage
module dut (output logic [31:0] o);
  function automatic fp::LL mk(); fp::LL h = new; return h; endfunction
  int r;
  initial begin fp::LL q; q = mk(); r = q.y; end
  assign o = 32'd0;
endmodule
