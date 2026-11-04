// § enumConstUnderscoreDropped186
module top(output int o);
  typedef enum int { A = 1_0, B = 2_000, C } e_t;
  e_t v;
  assign o = v;
endmodule
