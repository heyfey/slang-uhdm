// § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2);
endclass
module sub;
  c #(8) h;
  c #(8, 9) k;
endmodule
module a06;
  sub u();
endmodule
