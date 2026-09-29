// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [3:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  assign tq = din;
  for (genvar a = 0; a < 2; a++) begin : ga
    if (a == 0) begin : gif
      assign o[a*2+:2] = tq[a].pg[ix^a][1:0];
    end else begin : gel
      assign o[a*2+:2] = tq[a].pg[a][ix+:2];
    end
  end
endmodule
