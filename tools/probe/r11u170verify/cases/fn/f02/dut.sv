// § fnParamRangeNetNoFile163
class util;
  static function logic [7:0] rev(input logic [7:0] x);
    parameter len = 8;
    reg [len-1:0] r;
    for (int i = 0; i < len; i++) r[i] = x[len-1-i];
    return r;
  endfunction
endclass
module top; logic [7:0] y; initial y = util::rev(8'h0F); endmodule
