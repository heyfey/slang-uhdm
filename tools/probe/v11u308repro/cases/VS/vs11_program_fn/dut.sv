// § nonTrailIdxNamesByChain308
typedef struct packed { logic [7:0] f; } e_t;
program prg(input logic [3:0] i);
  e_t sa[16]; logic [7:0] r; logic [3:0] m[16];
  function automatic void probe(); r = sa[m[i] + 1].f; sa[i + 1].f = r; endfunction
  initial probe();
endprogram
module top(input logic [3:0] i); prg p(i); endmodule
