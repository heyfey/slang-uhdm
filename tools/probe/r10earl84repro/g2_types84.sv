// r10earl84 arm g2 — THE TYPESPEC-PRESENCE GRID.
// SEVENTEEN declared types, one localparam each, all holding the value 2, all
// read as the BASE of the indexed_part_select closing a hier_path in an ELAB
// port High_conn.  `CompileHelper::valueRange` reads VpiSigned off a
// logic_typespec / bit_typespec / int_typespec and NOTHING else, so exactly the
// SIGNED members of those three kinds carry the bare int_typespec.
package q84;
  parameter int QW = 8;
  parameter int QP = 2;
endpackage

module sink84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module types84;
  import q84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  typedef logic        [7:0] lu_t;
  typedef logic signed [7:0] ls_t;
  r_t reg2hw;

  localparam int          T01 = 2;
  localparam int signed   T02 = 2;
  localparam int unsigned T03 = 2;
  localparam integer      T04 = 2;
  localparam byte         T05 = 2;
  localparam shortint     T06 = 2;
  localparam longint      T07 = 2;
  localparam bit   [3:0]  T08 = 4'd2;
  localparam bit signed [3:0] T09 = 4'sd2;
  localparam logic [7:0]  T10 = 8'd2;
  localparam logic signed [7:0] T11 = 8'sd2;
  localparam signed [7:0] T12 = 8'sd2;
  localparam        [7:0] T13 = 8'd2;
  localparam lu_t         T14 = 8'd2;
  localparam ls_t         T15 = 8'sd2;
  localparam              T16 = 2;
  // A NEGATIVE base cannot be armed at this position at all: slang rejects
  // `q[-2 +: 8]` with -Wrange-oob and the whole file with it.  The helper
  // refuses `isNegative()` regardless (fence (f)).

  sink84 #(.W(QW)) u01 (.a(reg2hw.addr.q[T01 +: QW]));
  sink84 #(.W(QW)) u02 (.a(reg2hw.addr.q[T02 +: QW]));
  sink84 #(.W(QW)) u03 (.a(reg2hw.addr.q[T03 +: QW]));
  sink84 #(.W(QW)) u04 (.a(reg2hw.addr.q[T04 +: QW]));
  sink84 #(.W(QW)) u05 (.a(reg2hw.addr.q[T05 +: QW]));
  sink84 #(.W(QW)) u06 (.a(reg2hw.addr.q[T06 +: QW]));
  sink84 #(.W(QW)) u07 (.a(reg2hw.addr.q[T07 +: QW]));
  sink84 #(.W(QW)) u08 (.a(reg2hw.addr.q[T08 +: QW]));
  sink84 #(.W(QW)) u09 (.a(reg2hw.addr.q[T09 +: QW]));
  sink84 #(.W(QW)) u10 (.a(reg2hw.addr.q[T10 +: QW]));
  sink84 #(.W(QW)) u11 (.a(reg2hw.addr.q[T11 +: QW]));
  sink84 #(.W(QW)) u12 (.a(reg2hw.addr.q[T12 +: QW]));
  sink84 #(.W(QW)) u13 (.a(reg2hw.addr.q[T13 +: QW]));
  sink84 #(.W(QW)) u14 (.a(reg2hw.addr.q[T14 +: QW]));
  sink84 #(.W(QW)) u15 (.a(reg2hw.addr.q[T15 +: QW]));
  sink84 #(.W(QW)) u16 (.a(reg2hw.addr.q[T16 +: QW]));
  // a PACKAGE parameter in the same position — fence (c)
  sink84 #(.W(QW)) u18 (.a(reg2hw.addr.q[QP  +: QW]));
endmodule
