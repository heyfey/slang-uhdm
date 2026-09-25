// § fnParamRangeNetNoFile163
module top(input [3:0] a, output [7:0] z);
  generate if (1) begin : g
    function [7:0] f;
      input [3:0] a;
      parameter len = 8;
      reg [len-1:0] r;
      begin r = {4'b0, a}; f = r; end
    endfunction
    assign z = f(a);
  end endgenerate
endmodule
