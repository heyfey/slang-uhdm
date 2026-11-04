// § hierSelParenBoundPretty417
module top (input logic [5:0] off, output logic [7:0] o);
  typedef struct packed { logic [127:0] data; } line_s;
  line_s d;
  always_comb o = d.data[off*(2+1)+:8];
endmodule
