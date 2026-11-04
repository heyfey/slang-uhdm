// § defNetTypeParamDefault137
package p;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module bottom #(parameter type T = p::s_t)(output logic o);
  T d;
  assign o = d.a;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
