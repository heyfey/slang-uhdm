// § tfArgQualOutsideWriter176
package q;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module top;
  function automatic void f(ref q::s_t x);
    x.a = 4'd1;
  endfunction
  q::s_t v;
  initial f(v);
endmodule
