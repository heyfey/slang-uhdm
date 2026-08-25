// r10earl84 arm g3 — THE POSITION GRID.  ONE producer (`localparam int Db`),
// every select kind and slot, INSIDE and OUTSIDE a hier_path.  The law claims
// exactly one cell type: the BASE of a hier_path's trailing
// indexed_part_select in an ELAB port High_conn.
package r84;
  parameter int RW = 8;
endpackage

module sink84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module pos84;
  import r84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  logic [31:0] flat;
  logic [3:0][31:0] marr;
  localparam int Db = 2;

  // ---- INSIDE a hier_path -------------------------------------------------
  sink84 #(.W(RW)) h01 (.a(reg2hw.addr.q[Db    +: RW]));   // ips BASE   (+:)
  sink84 #(.W(RW)) h02 (.a(reg2hw.addr.q[Db+RW -: RW]));   // ips BASE   (-:) op
  sink84 #(.W(Db)) h03 (.a(reg2hw.addr.q[0     +: Db]));   // ips WIDTH
  sink84 #(.W(1))  h04 (.a(reg2hw.addr.q[Db]));            // bit_select IDX
  sink84 #(.W(2))  h05 (.a(reg2hw.addr.q[Db+1  :  Db]));   // part_select L/R
  sink84 #(.W(RW)) h06 (.a(reg2hw.addr.q[8     -: RW]));   // ips BASE literal

  // ---- OUTSIDE a hier_path ------------------------------------------------
  sink84 #(.W(RW)) b01 (.a(flat[Db    +: RW]));            // bare ips BASE
  sink84 #(.W(Db)) b02 (.a(flat[0     +: Db]));            // bare ips WIDTH
  sink84 #(.W(1))  b03 (.a(flat[Db]));                     // bare bit_select
  sink84 #(.W(2))  b04 (.a(flat[Db+1  :  Db]));            // bare part_select
  sink84 #(.W(RW)) b05 (.a(marr[1][Db +: RW]));            // var_select + ips

  // ---- the DEF-view twins are the very same lines, listed under ref_module
endmodule
