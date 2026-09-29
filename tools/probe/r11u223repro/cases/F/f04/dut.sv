// § tfArgScalarTdWriter223
package p;
  typedef bit my_bit_t;
  typedef int base_t;
  typedef base_t td2_t;
  class c;
    function void set(my_bit_t v, td2_t w);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  my_bit_t f; td2_t g;
endmodule
