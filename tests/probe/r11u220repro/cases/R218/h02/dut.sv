// § lvIdxPathRangeTailIsRead218
module top(input logic [7:0] x);
  typedef struct packed { logic [7:0] addr; } in_t;
  typedef struct packed { in_t b; logic c; } s_t;
  s_t s;
  logic [7:0] mem [16];
  function automatic void w(input logic [7:0] v); mem[s.b.addr[2 +: 2]] = v; endfunction
  always_comb w(x);
endmodule
