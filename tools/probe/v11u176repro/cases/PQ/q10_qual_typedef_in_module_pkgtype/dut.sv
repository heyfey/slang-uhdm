// § tfArgQualOutsideWriter176
package q;
  typedef logic [3:0] n_t;
  typedef struct packed { n_t a; } s_t;
endpackage
module top (input q::s_t si, output q::n_t o);
  function automatic q::n_t f(input q::s_t x);
    return x.a;
  endfunction
  assign o = f(si);
endmodule
