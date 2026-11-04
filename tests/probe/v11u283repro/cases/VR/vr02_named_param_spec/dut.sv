// § scopedClassRetQualSpan283
package fp;
  class PP #(int W = 4, type T = int); T y; endclass
endpackage
module dut (output logic [31:0] o);
  function automatic fp::PP#(.W(8), .T(bit)) mk(); return null; endfunction
  assign o = 32'd0;
endmodule
