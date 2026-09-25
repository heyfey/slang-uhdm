// § tfArgTypedefLastWriter146
module top(output int o);
  typedef enum logic [1:0] {A, B, C} e_t;
  class c;
    function int f(e_t x); return int'(x); endfunction
  endclass
  assign o = 0;
endmodule
