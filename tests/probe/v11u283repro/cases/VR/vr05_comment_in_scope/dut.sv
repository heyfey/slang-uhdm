// § scopedClassRetQualSpan283
package fp;
  class LL; int y; endclass
endpackage
module dut (output logic [31:0] o);
  function automatic fp /* c */ :: LL mk(); return null; endfunction
  assign o = 32'd0;
endmodule
