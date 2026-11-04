// § tfArgScalarTdWriter223
package p;
  typedef bit my_bit_t;
  typedef byte my_byte_t;
  typedef integer my_integer_t;
  typedef bit [3:0] nib_t;
  class c;
    function void set(my_bit_t v, input my_byte_t b, my_integer_t i, nib_t n);
    endfunction
  endclass
endpackage
module top;
  import p::*;
  my_bit_t f;
endmodule
