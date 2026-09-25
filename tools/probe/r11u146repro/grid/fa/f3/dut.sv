// § tfArgTypedefLastWriter146
module top(output int o);
typedef enum logic [1:0] {A, B, C} e_t;
function automatic int f(e_t g);
  return int'(g);
endfunction
  assign o = f(B);
endmodule
