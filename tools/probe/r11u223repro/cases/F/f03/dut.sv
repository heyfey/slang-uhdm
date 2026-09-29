// § tfArgScalarTdWriter223
package p;
  typedef logic [7:0] byte_t;
  class c;
    function void set(byte_t v);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  byte_t f;
endmodule
