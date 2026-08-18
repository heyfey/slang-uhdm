// v62d — INTERFACE-local typedefs across specializations (emitTypedefs also
// runs for interfaces; the implementer's u2r mover was exactly this shape),
// plus a hierarchical reference through the interface.
interface if62 #(parameter int W = 8) (input logic clk);
  typedef enum logic [1:0] { IA, IB, IC } i_op_e;
  typedef struct packed { i_op_e op; logic [W-1:0] d; } i_t;
  i_t   pkt;
  logic hit;
  assign hit = (pkt.op == IB);
  modport mp (input clk, output pkt, input hit);
endinterface

module use62 (if62 bus, output logic z);
  assign z = bus.hit;
endmodule

module top62d (input logic clk, output logic [1:0] o);
  if62 #(.W(8))  ia (.clk(clk));
  if62 #(.W(16)) ib (.clk(clk));
  logic za, zb;
  use62 ua (.bus(ia), .z(za));
  use62 ub (.bus(ib), .z(zb));
  assign o = {za, zb};
endmodule
