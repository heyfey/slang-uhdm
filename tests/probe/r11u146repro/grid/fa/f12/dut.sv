// § tfArgTypedefLastWriter146
module top;
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t g);
  return int'(g);
endfunction
endmodule
