// r11v40 v1_nodef40 — THE ADVERSARIAL ARM: AN ACTUAL THE GOLDEN REDUCER
// CANNOT EVALUATE, WRITTEN AS THE **BARE MEMBER CHAIN** THE LAW'S TWO ARMS DO
// SEE.
//
// § ovHopBareActualElabFold40 says "only an actual the reducer cannot evaluate
// keeps the written expression", and its abstain is implemented as "the
// parameter has a known integer value" — a SLANG-side question.  The producer's
// own failure mode is a DIFFERENT question: Surelog resolves the hop against
// the interface DEFINITION, so an interface parameter with NO DEFAULT has no
// def-side value at all while slang resolves it through the CONNECTED instance
// and always has one.
//
// If golden KEEPS the written operation here and the pristine binary kept it
// too, the law moves an AGREEING cell AWAY from golden.
//
// u_a 21 (the only instance; the interface parameter is override-only).
package pv40;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface ndif40 #(parameter pv40::cfg_t CFG);   // NO DEFAULT — override-only
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module ndinner40 #(parameter int unsigned W = 8)
                 (input logic clk,
                  input  logic [W-1:0] wdt,
                  output logic [W-1:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt;
  assign rdt = reg_data;
endmodule

module ndwrap40 (input logic clk, ndif40.sub s,
                 input logic [31:0] wdt, output logic [31:0] rdt);
  ndinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v1_nodef40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  ndif40 #(.CFG('{BUS: '{DAT: 21}})) s ();
  ndwrap40 u_a (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
endmodule
