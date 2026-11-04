// § hpTrailSelIdxNamesByPath133
// case tx05: trailing select index is a subtraction of two refs, in a function body
package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
endpackage
module dut(input logic [1:0] r, input logic [1:0] i, input logic [1:0] j, input logic [9:0] flat, output logic o);
  p::e_t [1:0] tbl;
  assign tbl = flat;
  function automatic logic pick(input logic [1:0] a, input logic [1:0] b);
    return tbl[r].sat[a - b];
  endfunction
  assign o = pick(i, j);
endmodule
