// § psBoundPaOwnerName192 § genForReplCountOwner192 § procPsBoundOwner192
`define SEL(v, b) v[b:0]
`define HI(v, b) v[31:b]
`define ZR(n) {n{1'b0}}
package p;
  parameter int unsigned W = 5;
endpackage
module sub import p::*; (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2 [2], output logic [31:0] y3);
  assign y1 = `SEL(x, W);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y2[i] = {`HI(x, W), `ZR(W)};
  end
  always_comb y3 = {`HI(x, W), `SEL(x, W-1)};
endmodule
module top (input logic [31:0] x, output logic [31:0] y1, output logic [31:0] y2 [2], output logic [31:0] y3);
  sub u (.*);
endmodule
