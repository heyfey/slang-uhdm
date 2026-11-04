// § tfArgQualOutsideWriter176
package q;
  typedef enum {A, B} e_t;
endpackage
program pr;
  function automatic int f(q::e_t x);
    return int'(x);
  endfunction
  int r;
  initial r = f(q::A);
endprogram
module top;
  pr u ();
endmodule
