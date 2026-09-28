// § modGenericClassListed196 § modGenericHandleBare196: a parameterized class extending a module-local plain class, and a plain class extending a module-local specialization
module sub ();
  class base;
    int b;
  endclass
  class der #(int W = 2) extends base;
    logic [W-1:0] x;
  endclass
  class leaf extends der #(5);
    int y;
  endclass
  der #(3) h1;
  leaf h2;
endmodule
module top;
  sub u ();
endmodule
