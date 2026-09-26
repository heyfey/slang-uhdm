// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module dut(input logic [1:0] i, output logic o);
  function automatic logic f(p::e_t x [2]);
    return x[0] == p::B;
  endfunction
  p::e_t a [2];
  assign a[0] = p::e_t'(i);
  assign a[1] = p::A;
  assign o = f(a);
endmodule
