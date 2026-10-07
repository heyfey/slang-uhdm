// § scopedClassRetQualSpan283
package fp;
  class OO;
    class II; int y; endclass
  endclass
endpackage
module dut (output logic [31:0] o);
  function automatic fp::OO::II mk(); return null; endfunction
  assign o = 32'd0;
endmodule
