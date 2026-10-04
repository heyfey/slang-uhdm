// § vlogEnumBaseKwSpan235
package vp;
  parameter W = 3;
  typedef enum logic [W-1:0] {IDLE, RUN, DONE} st_t;
endpackage
module top(input clk, input rst, output reg [2:0] o);
  vp::st_t s;
  always @(posedge clk) if (rst) s <= vp::IDLE; else s <= vp::RUN;
  always @* o = s;
endmodule
