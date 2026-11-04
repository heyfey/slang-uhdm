module top;
  class box #(int W = 4);
    logic [W-1:0] v;
  endclass
  box #(8) b;
endmodule
