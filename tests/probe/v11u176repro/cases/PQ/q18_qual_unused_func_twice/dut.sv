// § tfArgQualOutsideWriter176
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, output logic o);
  function automatic logic f(q::e_t x);
    return x == q::A;
  endfunction
  function automatic logic g(input q::e_t xx);
    return xx == q::B;
  endfunction
  assign o = f(s);
endmodule
