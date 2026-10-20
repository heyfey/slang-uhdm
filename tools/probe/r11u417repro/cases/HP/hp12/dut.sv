// § hierSelParenBoundPretty417
module top #(parameter int W = 64) (output logic [5:0] o);
  typedef struct packed { logic [63:0] paddr; } r_s;
  r_s d;
  assign o = d.paddr[$clog2(W)-1:0];
endmodule
