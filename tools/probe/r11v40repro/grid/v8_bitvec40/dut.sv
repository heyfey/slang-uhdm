// r11v40 v8_bitvec40 — THE FORMAL'S OWN TYPE, on legal SV.
//   u_v: the formal is `logic [7:0]` (a simple bit vector, value 21)
//   u_e: the formal is an ENUM type      (value 19)
//   u_i: the formal is `int unsigned`    (value 17, the law's own shape, control)
package pv40g;
  typedef struct packed { int unsigned D1; int unsigned D2; int unsigned D3; } cfg_t;
  typedef enum int unsigned { E17 = 17, E19 = 19 } e_t;
endpackage

interface bif40 #(parameter pv40g::cfg_t CFG = '{D1: 21, D2: 19, D3: 17});
  logic [31:0] data;
  modport sub (input data);
endinterface

module vinner40 #(parameter logic [7:0] W = 8'd8)
   (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  logic [W-1:0] reg_data;
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {11'd0, reg_data};
endmodule

module einner40 #(parameter pv40g::e_t W = pv40g::E17)
   (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  logic [W-1:0] reg_data;
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {13'd0, reg_data};
endmodule

module iinner40 #(parameter int unsigned W = 8)
   (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  logic [W-1:0] reg_data;
  always_ff @(posedge clk) reg_data <= wdt[W-1:0];
  assign rdt = {15'd0, reg_data};
endmodule

module vwrap40 (input logic clk, bif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  vinner40 #(.W(s.CFG.D1)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module ewrap40 (input logic clk, bif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  einner40 #(.W(pv40g::e_t'(s.CFG.D2))) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule
module iwrap40 (input logic clk, bif40.sub s, input logic [31:0] wdt, output logic [31:0] rdt);
  iinner40 #(.W(s.CFG.D3)) u_inner (.clk(clk), .wdt(wdt), .rdt(rdt));
endmodule

module v8_bitvec40 (input logic clk, input logic [31:0] wdt, output logic [31:0] rdt);
  bif40 s ();
  vwrap40 u_v (.clk(clk), .s(s.sub), .wdt(wdt), .rdt(rdt));
  ewrap40 u_e (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
  iwrap40 u_i (.clk(clk), .s(s.sub), .wdt(wdt), .rdt());
endmodule
