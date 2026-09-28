// § classValueParamIntSigned202
class c #(int W = 4, int unsigned U = 3);
  logic [W-1:0] v;
endclass
module p03; c #(8) h; endmodule
