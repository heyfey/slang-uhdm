// § tfArgTypedefLastWriter146
module top(input logic [1:0] i, output logic o);
  typedef enum logic [1:0] {A, B, C} e_t;
  function automatic logic isb(e_t x); return x == B; endfunction
  assign o = isb(e_t'(i));
endmodule
