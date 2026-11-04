// § scopedClassRetQualSpan283
class LL; int y; endclass
module dut (output logic [31:0] o);
  function automatic LL mk(); return null; endfunction
  assign o = 32'd0;
endmodule
