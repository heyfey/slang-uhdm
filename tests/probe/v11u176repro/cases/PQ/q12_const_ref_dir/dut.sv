// § tfArgQualOutsideWriter176
package q;
  typedef enum {A, B} e_t;
endpackage
module top;
  function automatic int f(const ref q::e_t x);
    return int'(x);
  endfunction
  q::e_t v;
  int r;
  initial r = f(v);
endmodule
