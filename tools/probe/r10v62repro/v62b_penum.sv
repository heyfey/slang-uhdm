// v62b — PARAM-DEPENDENT enum CONSTANT VALUES and enum BASE width across
// specializations.  If Surelog shares one enum_const object per definition,
// golden shows one value in both instances; if it specializes, sharing is
// wrong.  Also: the enum is read from a plain CA and from a pattern member.
module pe62 #(parameter int P = 1, parameter int EW = 2) (
  input  logic clk,
  output logic [3:0] o
);
  typedef enum logic [EW-1:0] { VA = P, VB = P + 1, VC = P + 2 } ve_t;
  typedef struct packed { ve_t op; logic e; } vs_t;
  vs_t vv;
  struct packed { logic x; logic y; } pk;
  assign pk = '{ x: (vv.op == VB), y: ((vv.op != VC) ? 1'b1 : 1'b0) };
  assign o  = { 2'b0, pk.x, pk.y } ^ { 2'b0, (vv.op == VA), vv.e };
endmodule

module top62b2 (input logic clk, output logic [7:0] o);
  logic [3:0] oa, ob;
  pe62 #(.P(1), .EW(2)) u_a (.clk(clk), .o(oa));
  pe62 #(.P(4), .EW(4)) u_b (.clk(clk), .o(ob));
  assign o = {oa, ob};
endmodule
