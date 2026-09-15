// r11v40 v5_depth40 — MEMBER DEPTH x VIEW, the face the brief names.
//
// One interface carrying a four-deep nested struct parameter; four children
// reached through the SAME modport hop, each overridden from a DIFFERENT member
// depth, plus the same override written inside a GENERATE loop and a child
// instantiated with NO override at all (the declaration default, the control
// that must not move).  Every value distinct so the typespec pool attributes
// each cell.
//
// d1 = 11 (depth 1)   d2 = 13 (depth 2)   d3 = 17 (depth 3)   d4 = 23 (depth 4)
// gen = 17 (depth 3, inside a generate for)   nov = 8 (the declaration default)
package pv40e;
  typedef struct packed { int unsigned LEAF; } l4_t;
  typedef struct packed { l4_t L4; int unsigned D3; } l3_t;
  typedef struct packed { l3_t L3; int unsigned D2; } l2_t;
  typedef struct packed { l2_t L2; int unsigned D1; } l1_t;
endpackage

interface dif40 #(parameter pv40e::l1_t CFG =
                    '{L2: '{L3: '{L4: '{LEAF: 23}, D3: 17}, D2: 13}, D1: 11});
  logic [CFG.D1-1:0] data;
  modport sub (input data);
endinterface

module dinner40 #(parameter int unsigned W = 8)
                (input logic clk,
                 input  logic [31:0] wdt,
                 output logic [31:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {9'd0, reg_data};
endmodule

module dw1_40 (input logic clk, dif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  dinner40 #(.W(s.CFG.D1)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module dw2_40 (input logic clk, dif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  dinner40 #(.W(s.CFG.L2.D2)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module dw3_40 (input logic clk, dif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  dinner40 #(.W(s.CFG.L2.L3.D3)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module dw4_40 (input logic clk, dif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  dinner40 #(.W(s.CFG.L2.L3.L4.LEAF)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module dwg_40 (input logic clk, dif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  for (genvar gi = 0; gi < 1; gi++) begin : g
    dinner40 #(.W(s.CFG.L2.L3.D3)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
  end
endmodule
module dwn_40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  dinner40 u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));   // NO OVERRIDE (8)
endmodule

module v5_depth40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  dif40 s ();
  dw1_40 u_d1 (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
  dw2_40 u_d2 (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
  dw3_40 u_d3 (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
  dw4_40 u_d4 (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
  dwg_40 u_dg (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
  dwn_40 u_dn (.clk(clk), .wdt(wdt), .rdt());
endmodule
