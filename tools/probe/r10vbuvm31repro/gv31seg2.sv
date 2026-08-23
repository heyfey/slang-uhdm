module v31segm2;
  class cg2 #(type T = int, int W = 2);
    T   d[];
    int w = W;
  endclass
  cg2 #(byte, 3) h = new();
  initial $display(h.d.size(), h.w);
endmodule
