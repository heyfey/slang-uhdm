// § tfArgTypedefLastWriter146
typedef enum logic [1:0] {A, B, C} e_t;
module m1(input logic [1:0] i, output logic o);
  function automatic logic isb(e_t x); return x == B; endfunction
  assign o = isb(e_t'(i));
endmodule
module top(input logic [1:0] i, output logic o, output logic q);
  function automatic logic isc(e_t y); return y == C; endfunction
  m1 u(.i(i), .o(o));
  assign q = isc(e_t'(i));
endmodule
