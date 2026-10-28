// § ifcAnsiLogicPortNet450
module bfm (
   input  logic       clk,
   output logic       frame,
   output logic [3:0] data
);
initial begin
  frame <= 0;
  data <= 0;
end
endmodule
module top;
  logic clk, f;
  logic [3:0] d;
  bfm u (.clk(clk), .frame(f), .data(d));
endmodule
