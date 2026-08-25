// r10v84 arm v6 — THE BIND FAMILY, all three positions.
//  b1  the BIND instance's own High_conn, base = the TARGET's localparam
//      (Surelog KEEPS the ref: createBindInstance_ parents the bind instance
//       at parent->getParent(), so high_conn_'s Reduce::Yes recompile has no
//       value for the target's parameter)
//  b2  a module instantiated INSIDE the bind module, base = the BIND MODULE's
//      own localparam (a normal child of a normal instance)
//  b3  the same shape in the ordinary, non-bind instantiation of the same
//      module — the positive control that the law still fires
module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module bnd6_84 (input logic [7:0] a);
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t inner;
  localparam int Nd = 3;
  sinkv84 #(.W(8)) u_b2 (.a(inner.addr.q[Nd +: 8]));   // b2
endmodule

module bindee6_84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Bd = 2;
endmodule

module top6_84;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  localparam int Td = 2;
  bindee6_84 u_be ();
  bnd6_84    u_plain (.a(reg2hw.addr.q[Td +: 8]));      // b3
endmodule

bind bindee6_84 bnd6_84 u_bind (.a(reg2hw.addr.q[Bd +: 8]));   // b1
