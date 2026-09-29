// § hpVarSelRangeIdxNamesByPath220
module sub #(parameter int W = 1)(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  typedef struct packed { logic [15:0] vpn; logic [1:0][3:0] pg; logic v; } s_t;
  s_t [1:0] tq;
  assign tq = din;
  for (genvar b = 0; b < 1; b++) begin : gb
    assign o = tq[b].pg[ix-W][1:0];
  end
endmodule
module mid(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  sub #(.W(1)) u(.din(din), .ix(ix), .o(o));
endmodule
module top(input logic [41:0] din, input logic [1:0] ix, output logic [1:0] o);
  mid m(.din(din), .ix(ix), .o(o));
endmodule
