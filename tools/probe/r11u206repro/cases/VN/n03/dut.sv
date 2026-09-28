// § modSpecValueArgSpanAtName202
class c #(int W = 1, int V = 2);
endclass
module n03;
  c #(.V(3)) j;
  c #(4) k;
endmodule
