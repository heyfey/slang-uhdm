// r11v40 v9_defchain40 — THE BOUND OF THE VERIFIER'S OWN FIX.
// The hop parameter HAS a default, but that default reads ANOTHER parameter
// that has none, so the definition-side value is still unavailable to the
// producer.  Measures whether "declared with a default" is the whole of the
// producer's abstain or only its first cut.
package pv40h;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface dcif40 #(parameter int unsigned BASE,
                   parameter pv40h::cfg_t CFG = '{BUS: '{DAT: BASE}});
  logic [31:0] data;
  modport sub (input data);
endinterface

module dcinner40 #(parameter int unsigned W = 8)
   (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {9'd0, reg_data};
endmodule

module dcwrap40 (input logic clk, dcif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  dcinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v9_defchain40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  dcif40 #(.BASE(23)) s ();
  dcwrap40 u_a (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
endmodule
