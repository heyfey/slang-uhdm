// (r11u191 const call) member reads: a struct formal from a parameter actual, from a literal pattern, a struct local, a struct module parameter
module top (output int o1, output int o2, output int o3, output int o4);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam s_t P = '{a: 4'd3, b: 4'd9};
  function automatic int h1(s_t s); h1 = s.b; endfunction
  function automatic int h3(int x); s_t t; t = 8'h5A; h3 = t.a; endfunction
  function automatic int h4(int x); h4 = P.b + x; endfunction
  assign o1 = h1(P);
  assign o2 = h1('{a: 4'd1, b: 4'd2});
  assign o3 = h3(1);
  assign o4 = h4(1);
endmodule
