// § nestedDefSecondBodyReadsRep307
module outer (input logic clk, input logic a, output logic y);
  module inner (input logic clk, input logic i, output logic o);
    logic r = 1'b0;
    task automatic t(input logic v); r <= v; endtask
    always @(posedge clk) t(i);
    assign o = r;
  endmodule
  inner u_i (.clk(clk), .i(a), .o(y));
endmodule
module dut (input logic clk, input logic [1:0] a, output logic [1:0] y);
  outer u_o (.clk(clk), .a(a[0]), .y(y[0]));
  outer u_p (.clk(clk), .a(a[1]), .y(y[1]));
endmodule
