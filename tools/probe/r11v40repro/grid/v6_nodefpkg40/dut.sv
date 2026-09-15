// r11v40 v6_nodefpkg40 — THE SAME BREAK AS v1, WRITTEN SO THE JUDGE CAN SEE IT.
//
// v1_nodef40 proved the census break (golden KEEPS the child's elaborated
// bound when the interface parameter has no default; the law folds it), but
// that arm's uhdm-cmp head sits on an unrelated struct-assignment-pattern
// residue that masks the cell on BOTH binaries.  Here the override actual is a
// PACKAGE parameter of the struct type, which both producers emit the same
// way, so the fold cell is the first thing the judge reaches.
//
// EXPECTATION IF THE LAW IS SOUND: both binaries score the same.
// WHAT IT MEASURES: whether an agreeing cell is moved away from golden.
package pv40f;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
  parameter cfg_t DEFCFG = '{BUS: '{DAT: 21}};
endpackage

interface ndif6_40 #(parameter pv40f::cfg_t CFG);   // NO DEFAULT — override-only
  logic [31:0] data;
  modport sub (input data);
endinterface

module ndinner6_40 #(parameter int unsigned W = 8)
                   (input logic clk,
                    input  logic [31:0] wdt,
                    output logic [31:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {11'd0, reg_data};
endmodule

module ndwrap6_40 (input logic clk, ndif6_40.sub s,
                   input logic [31:0] wdt, output logic [31:0] rdt);
  ndinner6_40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v6_nodefpkg40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  ndif6_40 #(.CFG(pv40f::DEFCFG)) s ();
  ndwrap6_40 u_a (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
endmodule
