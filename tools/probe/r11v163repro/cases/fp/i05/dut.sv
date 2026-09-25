// § fnParamRangeNetNoFile163
module sub #(parameter W = 4) (input [W-1:0] a, output [2*W-1:0] z);
  function [2*W-1:0] f;
    input [W-1:0] a;
    localparam len = 2*W;
    reg [len-1:0] r;
    begin r = {a, a}; f = r; end
  endfunction
  assign z = f(a);
endmodule
module top(input [3:0] a, output [7:0] z, input [2:0] b, output [5:0] y);
  sub s(.a(a), .z(z));
  sub #(.W(3)) t(.a(b), .z(y));
endmodule
