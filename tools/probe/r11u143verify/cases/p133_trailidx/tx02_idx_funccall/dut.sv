// § hpTrailSelIdxNamesByPath133
// case tx02: trailing select index is a function call over a port
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [9:0] flat, output logic o);
  function automatic logic [1:0] inc(input logic [1:0] x); return x + 1; endfunction
  p::e_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].sat[inc(i)];
endmodule
