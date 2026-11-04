// § tfArgDefTopSplit176
package p;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  function automatic logic f(s_t g);
    return g.b;
  endfunction
endpackage
module top (input p::s_t s, output logic o1, o2);
  function automatic logic h(p::s_t k);
    return k.a[0];
  endfunction
  assign o1 = p::f(s);
  assign o2 = h(s);
endmodule
