// § nonTrailIdxNamesByChain308
package pk;
  typedef struct packed { logic [7:0] f; } e_t;
  function automatic logic [7:0] g(e_t sa[16], logic [3:0] m[16], logic [3:0] i); return sa[m[i] + 1].f; endfunction
endpackage
module top; endmodule
