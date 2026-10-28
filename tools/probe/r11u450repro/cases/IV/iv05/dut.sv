// § ifcAnsiLogicPortNet450
interface bfm (
   input  logic       clk,
   output logic       frame
);
initial begin
  @(posedge clk);
  frame <= 0;
end
endinterface
module top;
  logic clk, f;
  bfm u (.clk(clk), .frame(f));
endmodule
