// § modGenericClassListed196 § modGenericHandleBare196: a generic class inside a generate block of the home, and a class-typed type parameter
module sub ();
  class item; int k; endclass
  class box #(type E = item);
    E v;
  endclass
  box #(item) b;
  if (1) begin : g
    class gbox #(int N = 3);
      int a [N];
    endclass
    gbox #(4) q;
  end
endmodule
module top;
  sub v ();
endmodule
