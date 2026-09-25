// § hpDotWsTrimmed167
module top (input logic [7:0] a, output logic [7:0] y);
  typedef struct packed { logic [7:0] wdtxx; } s_t;
  s_t bs;
  always_comb begin
    bs = a;
    y = bs. wdtxx;
  end
endmodule
