// § tfArgTypedefLastWriter146
typedef enum logic [1:0] {A, B, C} e_t;
module top(input logic [1:0] i, output logic o);
  function automatic logic isb(e_t x); return x == B; endfunction
  assign o = isb(e_t'(i));
endmodule
