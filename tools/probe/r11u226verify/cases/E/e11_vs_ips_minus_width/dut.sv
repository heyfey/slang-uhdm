// § hpVarSelIpsDirectRefSkipsSelect220 § hpVarSelRangeIdxNamesByPath220 — a trailing var_select ending in -: and +: with a reference base and a parameter width, and an operation base
module top #(parameter int W = 2)(input logic [31:0] din, input logic [1:0] i, input logic [2:0] k, output logic [1:0] o1, output logic [1:0] o2, output logic [1:0] o3);
  typedef struct packed { logic [3:0][7:0] pg; } s_t;
  s_t tq [2];
  assign tq[0] = din;
  assign tq[1] = ~din;
  assign o1 = tq[1].pg[i][k -: W];
  assign o2 = tq[0].pg[i][k +: W];
  assign o3 = tq[1].pg[i][k+1 +: 2];
endmodule
