// § tfArgTypedefLastWriter146
package p;
  typedef enum logic {A, B} e_t;
  function automatic logic g(e_t x); return x == B; endfunction
  function automatic logic h(logic a, e_t y); return y == A; endfunction
endpackage
module top(output logic o, output logic q);
  import p::*;
  assign o = g(A);
  assign q = h(1'b0, B);
endmodule
