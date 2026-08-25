// r10earl84 arm g4 — THE PRODUCER GRID.  Every way a name in the BASE slot can
// get a value: a module localparam, a module parameter NOT overridden, the
// same parameter OVERRIDDEN (three different actuals), a gen-scope localparam,
// a genvar, a package parameter, and a value only an expression can give.
package s84;
  parameter int SW = 8;
  parameter int SP = 3;
endpackage

module sink84 #(parameter int W = 8) (input logic [W-1:0] a);
endmodule

module mid84 #(parameter int MP = 3,
               parameter int MQ = 3,
               parameter bit [3:0] MB = 4'd3)
              (input logic [7:0] a);
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;
  sink84 #(.W(8)) u_mp (.a(reg2hw.addr.q[MP +: 8]));   // NOT overridden
  sink84 #(.W(8)) u_mq (.a(reg2hw.addr.q[MQ +: 8]));   // OVERRIDDEN
  sink84 #(.W(8)) u_mb (.a(reg2hw.addr.q[MB +: 8]));   // OVERRIDDEN, based
endmodule

module prod84;
  import s84::*;
  typedef struct packed { logic [31:0] q; } f_t;
  typedef struct packed { f_t addr;      } r_t;
  r_t reg2hw;

  localparam int Lp   = 2;
  localparam int Lx   = 1 + 1;          // expression initialiser
  localparam int Lc   = $clog2(4);      // system-call initialiser

  sink84 #(.W(SW)) p01 (.a(reg2hw.addr.q[Lp +: SW]));
  sink84 #(.W(SW)) p02 (.a(reg2hw.addr.q[Lx +: SW]));
  sink84 #(.W(SW)) p03 (.a(reg2hw.addr.q[Lc +: SW]));
  sink84 #(.W(SW)) p04 (.a(reg2hw.addr.q[SP +: SW]));   // package parameter

  mid84 #(.MQ(5), .MB(4'h6)) u_m1 (.a(8'd0));
  mid84 #(.MQ(7), .MB(4'd2)) u_m2 (.a(8'd0));
  mid84                      u_m3 (.a(8'd0));           // nothing overridden

  for (genvar gi = 0; gi < 2; gi++) begin : gb
    localparam int GL = gi + 1;
    sink84 #(.W(SW)) g01 (.a(reg2hw.addr.q[gi +: SW]));   // genvar
    sink84 #(.W(SW)) g02 (.a(reg2hw.addr.q[GL +: SW]));   // gen localparam
  end
endmodule
