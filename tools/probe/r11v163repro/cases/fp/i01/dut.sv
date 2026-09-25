// § fnParamRangeNetNoFile163
package pk;
  function automatic [7:0] f(input [3:0] a);
    parameter len = 8;
    reg [len-1:0] r;
    begin r = {4'b0, a}; f = r; end
  endfunction
endpackage
module top(input [3:0] a, output [7:0] z);
  assign z = pk::f(a);
endmodule
