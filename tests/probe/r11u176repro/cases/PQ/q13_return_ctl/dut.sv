// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut(input logic [1:0] i, output p::e_t o);
  function automatic p::e_t f(logic [1:0] x);
    return p::e_t'(x);
  endfunction
  assign o = f(i);
endmodule
