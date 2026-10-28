// § ifcAnsiLogicPortNet450
typedef enum logic [1:0] {IDLE, RUN} st_e;
typedef logic [5:0] six_t;
interface bfm (input logic clk, output st_e st, output six_t six);
initial begin
  st = IDLE;
  six = 0;
end
endinterface
module top;
  logic clk; st_e s; six_t x;
  bfm u (.clk(clk), .st(s), .six(x));
endmodule
