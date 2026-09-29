// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [3:0] en, output logic [3:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  assign tq = din;
  for (genvar gi = 0; gi < 2; gi++) begin : g_i
    for (genvar gx = 1; gx < 3; gx++) begin : g_x
      wire [1:0] loc;
      assign loc = tq[gi].pg[2-gx][gx-1+:2];
      assign o[gi*2+gx-1] = |loc;
    end
  end
endmodule
