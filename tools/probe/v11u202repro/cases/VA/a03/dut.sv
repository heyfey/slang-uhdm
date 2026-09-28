// § modSpecValueArgSpanAtName202
class c #(int W = 1);
endclass
module sub #(parameter P = 3);
  c #(P) h;
  c #(P+1) h2;
  c #(
     4) h3;
endmodule
module a03;
  sub #(5) u();
  sub u2();
endmodule
