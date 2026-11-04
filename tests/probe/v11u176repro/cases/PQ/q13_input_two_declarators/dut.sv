// § tfArgQualOutsideWriter176
package q;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module top (input q::e_t s, t, output logic o);
  function automatic logic f(input q::e_t x, y);
    return x == y;
  endfunction
  assign o = f(s, t);
endmodule
