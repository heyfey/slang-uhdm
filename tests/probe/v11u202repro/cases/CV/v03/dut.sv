// § classValueParamIntSigned202
module v03;
  class c #(parameter int W = 4);
    bit [W-1:0] v;
  endclass
  c #(8) h;
endmodule
