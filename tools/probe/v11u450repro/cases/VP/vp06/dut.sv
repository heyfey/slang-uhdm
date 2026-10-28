// § ifcAnsiLogicPortNet450
interface bfm (input logic clk, output logic f, output logic [7:0] d);
always @(posedge clk) begin
  f <= ~f;
  d <= d + 1;
end
endinterface
module top;
  logic clk;
  logic f0, f1, f2; logic [7:0] d0, d1, d2;
  bfm u0 (.clk(clk), .f(f0), .d(d0));
  bfm u1 (.clk(clk), .f(f1), .d(d1));
  for (genvar g = 0; g < 1; g++) begin : gb
    bfm ug (.clk(clk), .f(f2), .d(d2));
  end
endmodule
