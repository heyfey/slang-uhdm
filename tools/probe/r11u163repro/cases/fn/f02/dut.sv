// § fnParamRangeNetNoFile163
module m(input [3:0] a, output reg [7:0] z);
  task t;
    input [3:0] x;
    parameter W = 8;
    reg [W-1:0] r;
    begin
      r = x;
      z = r;
    end
  endtask
  always @* t(a);
endmodule
module top(input [3:0] a, output [7:0] z); m u(.a(a), .z(z)); endmodule
