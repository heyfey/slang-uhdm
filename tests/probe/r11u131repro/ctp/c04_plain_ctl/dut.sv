// § castTsPushLaidOut131
// case c04_plain_ctl
module top(input logic [15:0] a, output logic [5:0] o);
  assign o = 6'(a) + int'(a[1:0]);
endmodule
