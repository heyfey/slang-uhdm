// § hierSelParenBoundPretty417
module top (input logic [5:0] off, output logic [7:0] o);
  typedef struct packed { logic [127:0] data; } line_s;
  line_s d;
  always_comb begin
    o = '0;
    for (int i = 0; i < 2; i++)
      o = d.data[(off+i*8)+:8];
  end
endmodule
