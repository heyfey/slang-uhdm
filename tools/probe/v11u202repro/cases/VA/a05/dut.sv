// § modSpecValueArgDefViewMultiArg202v
class c #(int W = 1, int V = 2);
endclass
module a05;
  c #(8) h;
  c #(8, 9) k;
  c #(.W(8)) j;
endmodule
