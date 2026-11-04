// § ifcAnsiLogicPortNet450
package p;
  int k;
endpackage
interface bfm (
   input  logic       clk,
   output logic       frame,
   output logic [3:0] data
);
import p::*;
initial begin
  frame <= 0;
  data <= 0;
end
endinterface
module top;
  logic clk, f;
  logic [3:0] d;
  bfm u (.clk(clk), .frame(f), .data(d));
endmodule
