// § tfArgQualOutsideWriter176
package q;
  typedef struct { int a; int b; } u_t;
endpackage
module top;
  function automatic int f(q::u_t x);
    return x.a;
  endfunction
  q::u_t v;
  int r;
  initial r = f(v);
endmodule
