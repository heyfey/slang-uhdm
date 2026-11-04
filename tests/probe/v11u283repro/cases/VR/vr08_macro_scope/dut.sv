// § scopedClassRetQualSpan283
`define PK fp
package fp;
  class LL; int y; endclass
endpackage
module dut (output logic [31:0] o);
  function automatic `PK::LL mk(); return null; endfunction
  assign o = 32'd0;
endmodule
