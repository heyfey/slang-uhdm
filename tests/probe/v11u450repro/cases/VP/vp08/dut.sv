// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output reg r, output logic signed [3:0] s, output reg [2:0] r3);
initial begin
  r = 0;
  s = 0;
  r3 = 0;
end
endinterface
module top;
  logic clk, rr; logic signed [3:0] ss; logic [2:0] rr3;
  bfm u (.clk(clk), .r(rr), .s(ss), .r3(rr3));
endmodule
