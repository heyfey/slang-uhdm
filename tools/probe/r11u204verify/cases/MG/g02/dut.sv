// § modGenericClassListed196 § modGenericHandleBare196: a class nested in a module-local parameterized class, handles of both and a type+value specialization
module sub ();
  class outer #(type T = int, int N = 2);
    class inner;
      int k;
    endclass
    T arr [N];
    inner h;
  endclass
  outer #(byte, 3) o1;
  outer #(.T(shortint)) o2;
endmodule
module top;
  sub u ();
endmodule
