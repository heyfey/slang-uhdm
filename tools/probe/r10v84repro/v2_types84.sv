// r10v84 arm v2 — DECLARED TYPES THE IMPLEMENTER'S GRID DID NOT HOLD.
// Typedefs to int / bit signed, `reg signed`, a SCALAR signed logic, MULTI-
// DIMENSION packed (signed and not), `time`, a >64-bit vector, and a zero
// value.  Every one is the BASE of the ips closing a hier_path in an ELAB
// port High_conn.
package qv84;
  parameter int QW = 8;
endpackage

module sinkv84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module types2_84;
  import qv84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;

  typedef int              int_t;
  typedef bit signed [3:0] bs_t;
  typedef byte             byte_t;

  localparam int_t              V01 = 2;        // typedef -> int (signed)
  localparam bs_t               V02 = 4'sd2;    // typedef -> bit signed
  localparam byte_t             V03 = 2;        // typedef -> byte
  localparam reg signed [7:0]   V04 = 8'sd2;    // reg signed
  localparam logic signed       V05 = 1'sb0;    // SCALAR signed logic, value 0
  localparam bit signed [1:0][3:0] V06 = 8'sd2; // 2-dim packed, signed
  localparam logic [1:0][3:0]   V07 = 8'd2;     // 2-dim packed, unsigned
  localparam bit                V08 = 1'b1;     // scalar bit
  localparam time               V09 = 2;        // time
  localparam logic [70:0]       V10 = 71'd2;    // wider than 64 bits
  localparam int                V11 = 0;        // the zero value

  sinkv84 #(.W(QW)) v01 (.a(reg2hw.addr.q[V01 +: QW]));
  sinkv84 #(.W(QW)) v02 (.a(reg2hw.addr.q[V02 +: QW]));
  sinkv84 #(.W(QW)) v03 (.a(reg2hw.addr.q[V03 +: QW]));
  sinkv84 #(.W(QW)) v04 (.a(reg2hw.addr.q[V04 +: QW]));
  sinkv84 #(.W(QW)) v05 (.a(reg2hw.addr.q[V05 +: QW]));
  sinkv84 #(.W(QW)) v06 (.a(reg2hw.addr.q[V06 +: QW]));
  sinkv84 #(.W(QW)) v07 (.a(reg2hw.addr.q[V07 +: QW]));
  sinkv84 #(.W(QW)) v08 (.a(reg2hw.addr.q[V08 +: QW]));
  sinkv84 #(.W(QW)) v09 (.a(reg2hw.addr.q[V09 +: QW]));
  sinkv84 #(.W(QW)) v10 (.a(reg2hw.addr.q[V10 +: QW]));
  sinkv84 #(.W(QW)) v11 (.a(reg2hw.addr.q[V11 +: QW]));
endmodule
