// § procCheckerIsCheckerInst401
checker c1(event clk, logic [7:0] a);
  p1: assert property (@clk a != 0);
endchecker
module m(input logic clk, logic en, logic [7:0] in1);
  always @(posedge clk) begin
    if (en) begin
      c1 check_inside(posedge clk, in1);
    end
  end
endmodule
