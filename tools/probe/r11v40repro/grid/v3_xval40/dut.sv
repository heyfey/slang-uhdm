// r11v40 v3_xval40 — THE ABSTAIN'S OWN FACE: a bare member chain whose value
// carries UNKNOWN bits, and one whose formal is 4-state but fully known.
//
// `ovHopBareActualFolds40` answers FALSE when the parameter's value is not a
// known integer (`!cv.integer().hasUnknown()`).  This arm makes that branch
// fire on legal SV and asks what golden does there, so the abstain is measured
// rather than assumed.
//
// u_x: the member is 8'bxxxx_xxxx  -> predicate FALSE (keeps)
// u_k: the member is 8'd19         -> predicate TRUE  (folds); the control
package pv40c;
  typedef struct packed { logic [7:0] DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface xif40 #(parameter pv40c::cfg_t CFG = '{BUS: '{DAT: 8'd24}});
  logic [7:0] data;
  modport sub (input data);
endinterface

module xinner40 #(parameter logic [7:0] W = 8'd8)
                (input logic clk,
                 input  logic [31:0] wdt,
                 output logic [31:0] rdt);
  logic [W-1:0] reg_data;              // THE WITNESS CELL
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {24'd0, reg_data[7:0]};
endmodule

module xwrap40 (input logic clk, xif40.sub s,
                input logic [31:0] wdt, output logic [31:0] rdt);
  xinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v3_xval40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  xif40 #(.CFG('{BUS: '{DAT: 8'bxxxxxxxx}})) s_x ();
  xif40 #(.CFG('{BUS: '{DAT: 8'd19}}))       s_k ();
  xwrap40 u_x (.clk(clk), .s(s_x.sub), .wdt(wdt), .rdt(rdt));
  xwrap40 u_k (.clk(clk), .s(s_k.sub), .wdt(wdt), .rdt());
endmodule
