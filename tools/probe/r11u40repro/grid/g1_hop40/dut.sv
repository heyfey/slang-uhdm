// r11u40 g1_hop40 — THE HOP KIND.
// One child module (inner40) whose body variable's packed range reads its own
// parameter W.  The parent overrides W through a different HOP on every arm.
// The question: which hops make Surelog's netlist elaboration FOLD the child's
// ELABORATED range, and which make it keep the written operation.
//
// EVERY ARM'S W IS A DISTINCT VALUE, so the design-level typespec POOL's
// multiset of bound encodings attributes each cell to its arm without needing
// the owner chain (uhdm-dump prints a pooled typespec's content once).
//   u_a 32  u_b 12  u_c 24  u_d 20  u_e 22  u_f 28  u_g 18  u_h 14  u_i 16
package p40;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface tif40 #(parameter p40::cfg_t CFG = '{BUS: '{DAT: 32}},
                  parameter int unsigned PW = 12);
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module inner40 #(parameter int unsigned W = 8)
               (input logic clk,
                input  logic [W-1:0] wdt,
                output logic [W-1:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL (iface_param_2level 16:10)
  always_ff @(posedge clk) reg_data <= wdt;
  assign rdt = reg_data;
endmodule

// A — the corpus shape: a MODPORT port, member depth 3.
module w_mp40 (input logic clk, tif40.sub s,
               input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// B — a MODPORT port, a PLAIN int parameter (member depth 0).
module w_mp1_40 (input logic clk, tif40.sub s,
                 input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(s.PW)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// C — a PLAIN interface port (no modport), member depth 3, CFG.BUS.DAT = 24.
module w_pi40 (input logic clk, tif40 s,
               input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// D — NO HOP: the parent's own module parameter (the control).
module w_mod40 #(parameter int unsigned TW = 20)
               (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(TW)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// E — NO HOP, an EXPRESSION of the parent's own module parameter (26-4 = 22).
module w_mode40 #(parameter int unsigned TW = 26)
                (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(TW-4)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// F — NO HOP: the parent's own STRUCT parameter's MEMBER (r11u4's family).
module w_sp40 #(parameter p40::cfg_t CFGP = '{BUS: '{DAT: 28}})
              (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(CFGP.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// G — a PACKAGE parameter (no instance hop at all).
package q40;
  parameter int unsigned QW = 18;
endpackage
module w_pkg40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(q40::QW)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

// H — TWO HOPS: a modport port RE-PASSED to a second wrapper's modport port,
//     whose own child reads the member (14 through tif14).
module w_mp_lvl2_40 (input logic clk, tif40.sub s,
                     input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module w_mp_lvl1_40 (input logic clk, tif40.sub s,
                     input logic [31:0] wdt, output logic [31:0] rdt);
  w_mp_lvl2_40 u_mid (.clk(clk), .s(s), .wdt(wdt), .rdt(rdt));
endmodule

// I — an INTERFACE ARRAY element's member, through a modport port (16).
module w_arr40 (input logic clk, tif40.sub sa,
                input logic [31:0] wdt, output logic [31:0] rdt);
  inner40 #(.W(sa.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module g1_hop40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  tif40                                       s ();   // CFG.BUS.DAT = 32, PW = 12
  tif40 #(.CFG('{BUS: '{DAT: 24}}))           s2();
  tif40 #(.CFG('{BUS: '{DAT: 14}}))           s3();
  tif40 #(.CFG('{BUS: '{DAT: 16}}))           sarr [2:0] ();
  w_mp40       u_a (.clk(clk), .s(s.sub),      .wdt(wdt), .rdt(rdt));
  w_mp1_40     u_b (.clk(clk), .s(s.sub),      .wdt(wdt), .rdt());
  w_pi40       u_c (.clk(clk), .s(s2),         .wdt(wdt), .rdt());
  w_mod40      u_d (.clk(clk), .wdt(wdt), .rdt());
  w_mode40     u_e (.clk(clk), .wdt(wdt), .rdt());
  w_sp40       u_f (.clk(clk), .wdt(wdt), .rdt());
  w_pkg40      u_g (.clk(clk), .wdt(wdt), .rdt());
  w_mp_lvl1_40 u_h (.clk(clk), .s(s3.sub),     .wdt(wdt), .rdt());
  w_arr40      u_i (.clk(clk), .sa(sarr[1].sub), .wdt(wdt), .rdt());
endmodule
