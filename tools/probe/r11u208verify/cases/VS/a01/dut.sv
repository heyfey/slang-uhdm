// § modSpecValueArgSpanAtName202 § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2);
  logic [W-1:0] x;
endclass
module a01 #(parameter P = 3);
  c #(P) h1;
  c #(8+1) h2;
  c #(4) h3, h4;
  c #(P, P+1) h5;
  c #(2) h6 = new;
endmodule
