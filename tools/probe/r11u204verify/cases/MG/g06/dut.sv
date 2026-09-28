// § modGenericClassListed196 § modGenericHandleBare196: an interface home with a value parameter and a type parameter (pass 196's R8: Surelog publishes an interface's classes at the design root)
interface ifc ();
  class pkt #(int W = 8, type T = bit);
    T [W-1:0] d;
  endclass
  pkt #(4) p0;
  pkt #(2, logic) p1;
endinterface
module top;
  ifc u ();
endmodule
