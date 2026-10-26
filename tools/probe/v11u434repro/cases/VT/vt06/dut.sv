// § modTdRangeClogKeeps434
module top #(parameter W = 8);
  if (W > 1) begin : g
    typedef logic [$clog2(W)-1:0] t;
    t x;
  end
endmodule
