// § tfArgQualOutsideWriter176
`define PT(a) q::a``_t
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, output logic o);
  function automatic logic f(`PT(e) x);
    return x == q::A;
  endfunction
  assign o = f(s);
endmodule
