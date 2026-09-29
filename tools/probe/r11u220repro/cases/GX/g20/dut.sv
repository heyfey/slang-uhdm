// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  logic [1:0] arr [2];
  assign tq = din;
  assign arr[0] = ix; assign arr[1] = ~ix;
  assign o = tq[0].pg[arr[1]][1:0];
endmodule
