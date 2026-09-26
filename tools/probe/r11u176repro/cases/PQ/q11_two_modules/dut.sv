// § tfArgQualOutsideWriter176
package p;
  typedef enum logic [1:0] {A, B, C} e_t;
endpackage
module zz(input logic [1:0] i, output logic o);
  function automatic logic f(p::e_t x);
    return x == p::B;
  endfunction
  assign o = f(p::e_t'(i));
endmodule
module aa(input logic [1:0] i, output logic o);
  function automatic logic f(p::e_t x);
    return x == p::C;
  endfunction
  assign o = f(p::e_t'(i));
endmodule
module dut(input logic [1:0] i, output logic o, q);
  zz u1(i, o);
  aa u2(i, q);
endmodule
