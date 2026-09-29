// § hpVarSelRangeIdxNamesByPath220
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq2;
  always_comb begin
    tq2 = din;
    tq2[0].pg[ix][1:0] = 2'b0;
  end
  assign o = tq2[0].pg[ix][1:0];
endmodule
