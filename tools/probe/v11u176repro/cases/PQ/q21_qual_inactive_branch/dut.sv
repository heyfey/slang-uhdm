// § tfArgQualOutsideWriter176
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, output logic o);
`ifdef NOPE
  function automatic logic g(q::e_t zz);
    return zz == q::C;
  endfunction
`endif
  function automatic logic f(q::e_t x);
    return x == q::A;
  endfunction
  assign o = f(s);
endmodule
