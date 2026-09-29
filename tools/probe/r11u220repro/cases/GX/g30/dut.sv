// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  int i;
  assign tq = din;
  always_comb begin
    o = '0;
    for (i = 0; i < 2; i++) o = o ^ tq[i].pg[i+1][ix-:2];
  end
endmodule
