// § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2, int X = 3);
endclass
module a07;
  c #(1, 2, 3) h;
  c #(4, 5) k;
endmodule
