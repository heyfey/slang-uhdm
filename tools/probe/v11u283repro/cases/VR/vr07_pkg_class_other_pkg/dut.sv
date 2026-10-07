// § scopedClassRetQualSpan283
package fp;
  class LL; int y; endclass
endpackage
package gp;
  class MM;
    static function fp::LL mk(); return null; endfunction
    extern function fp::LL mk2();
  endclass
  function fp::LL MM::mk2(); return null; endfunction
endpackage
module dut (output logic [31:0] o);
  assign o = 32'd0;
endmodule
