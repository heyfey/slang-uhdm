// § tfArgQualOutsideWriter176
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module m1 (input q::e_t s, output logic o);
  function automatic logic f(q::e_t x);
    return x == q::B;
  endfunction
  assign o = f(s);
endmodule
module top (input q::e_t s, output logic o1, o2);
  import q::*;
  function automatic logic g(e_t x);
    return x == C;
  endfunction
  m1 u (.s(s), .o(o1));
  assign o2 = g(s);
endmodule
