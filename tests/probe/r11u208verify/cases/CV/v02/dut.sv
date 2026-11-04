// § classValueParamIntSigned202
module v02;
  class lc #(int W = 4, parameter int unsigned X = 1);
    logic [W-1:0] v;
  endclass
  lc #(8) a;
  lc b;
endmodule
class gc #(localparam int Q = 3, int R = Q);
endclass
module v02b; gc h; v02 u(); endmodule
