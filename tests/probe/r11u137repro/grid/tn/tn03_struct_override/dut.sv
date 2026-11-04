// § defNetTypeParamDefault137
package p;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module sub #(parameter type T = logic);
  T r;
  always_comb r = '0;
endmodule
module top ();
  sub #(.T(p::s_t)) u();
endmodule
