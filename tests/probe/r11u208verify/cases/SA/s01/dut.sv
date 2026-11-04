// § sysCtxRefArgBare201
module s01 (input logic [3:0] a, input logic [7:0] w, output logic [31:0] y1, output logic [31:0] y2, output logic [31:0] y3, output logic [31:0] y4);
  typedef struct packed { logic [3:0] m; logic [3:0] n; } st_t;
  st_t st;
  assign st = w;
  function automatic logic [3:0] f(input logic [3:0] x); return ~x; endfunction
  function automatic logic [3:0] g(input logic [3:0] x); return x + 4'd1; endfunction
  function automatic logic [3:0] h(input logic [3:0] x); return x ^ 4'd3; endfunction
  assign y1 = $countones(f(st.m));
  assign y2 = $countones(f({a[1:0], w[1:0]}));
  assign y3 = $countones(g(f(w[7:4])));
  assign y4 = $countones(h(g(f(a))));
endmodule
