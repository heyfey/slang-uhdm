// r11v40 v4_structformal40 — THE FORMAL THE PREDICATE CANNOT ANSWER FOR.
//
// `ovHopBareActualFolds40` asks `p.getValue().isInteger()`.  A formal that is
// itself a STRUCT parameter, overridden across the hop by a bare member chain
// and read MEMBER-WISE in a bound, answers FALSE — so the law abstains and we
// keep the written operation.  Does golden keep it too?
//
// u_s: the formal is a struct parameter (`B`), the bound reads `B.DAT` (25)
// u_i: the formal is an int parameter (the law's own shape), value 25 (control)
package pv40d;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { bus_t BUS; } cfg_t;
endpackage

interface sif40 #(parameter pv40d::cfg_t CFG = '{BUS: '{DAT: 25}});
  logic [CFG.BUS.DAT-1:0] data;
  modport sub (input data);
endinterface

module sinner40 #(parameter pv40d::bus_t B = '{DAT: 8})
                (input logic clk,
                 input  logic [31:0] wdt,
                 output logic [31:0] rdt);
  logic [B.DAT-1:0] reg_data;          // THE WITNESS CELL (struct formal)
  always_ff @(posedge clk) reg_data <= wdt[B.DAT-1:0];
  assign rdt = {7'd0, reg_data};
endmodule

module iinner40 #(parameter int unsigned W = 8)
                (input logic clk,
                 input  logic [31:0] wdt,
                 output logic [31:0] rdt);
  logic [W-1:0] reg_data;              // the control cell (int formal)
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {7'd0, reg_data};
endmodule

module swrap40 (input logic clk, sif40.sub s,
                input logic [31:0] wdt, output logic [31:0] rdt);
  sinner40 #(.B(s.CFG.BUS)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module iwrap40 (input logic clk, sif40.sub s,
                input logic [31:0] wdt, output logic [31:0] rdt);
  iinner40 #(.W(s.CFG.BUS.DAT)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v4_structformal40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  sif40 s ();
  swrap40 u_s (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
  iwrap40 u_i (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
endmodule
