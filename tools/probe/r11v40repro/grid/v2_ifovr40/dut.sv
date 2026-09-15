// r11v40 v2_ifovr40 — THE VALUE FACE OF THE SAME SHAPE (r11u40's R1, on the
// corpus's OWN hop kind).
//
// `iface_param_2level` converts because its interface is instantiated WITHOUT
// an override, so the definition default Surelog reads and the connected value
// slang reads are the same number.  This arm is the corpus shape with the
// interface parameter OVERRIDDEN at the instantiation, which is ordinary legal
// SV: golden then folds the DEFINITION default (32 -> 31) while our fold reads
// the connected instance (26 -> 25).
//
// The question the verdict needs: is the pristine cell EQUAL to golden here?
// If it is, the law moves an agreeing cell away.  If it is not, the law is
// MOVED-WRONG on the value residue and the conversion is value-coincidence.
//
// u_a: interface overridden to 26, modport hop, member depth 3.
// u_b: interface at its default 32, plain interface port (the control).
package pv40b;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface tifv40 #(parameter pv40b::cfg_t CFG = '{BUS: '{DAT: 32}});
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module vinner40 #(parameter int unsigned W = 8)
                (input logic clk,
                 input  logic [W-1:0] wdt,
                 output logic [W-1:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt;
  assign rdt = reg_data;
endmodule

module vwrap_a40 (input logic clk, tifv40.sub s,
                  input logic [31:0] wdt, output logic [31:0] rdt);
  vinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module vwrap_b40 (input logic clk, tifv40.sub s,
                  input logic [31:0] wdt, output logic [31:0] rdt);
  vinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v2_ifovr40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  tifv40 #(.CFG('{BUS: '{DAT: 26}})) s_ovr ();
  tifv40                             s_def ();
  vwrap_a40 u_a (.clk(clk), .s(s_ovr.sub), .wdt(wdt), .rdt(rdt));
  vwrap_b40 u_b (.clk(clk), .s(s_def.sub), .wdt(wdt), .rdt());
endmodule
