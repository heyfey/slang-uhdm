// § lvIdxPathIsRead154
interface tif; logic [2:0] off; modport sub(input off); endinterface
module mem(tif.sub sub, input logic clk, input logic [1:0] d, output logic [7:0] r);
  always_ff @(posedge clk) r[sub.off +: 2] <= d;
endmodule
module top(input logic clk, input logic [1:0] d, output logic [7:0] r); tif b(); mem u(.sub(b), .clk(clk), .d(d), .r(r)); endmodule
