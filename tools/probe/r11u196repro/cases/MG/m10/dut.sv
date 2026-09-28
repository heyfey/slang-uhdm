// § modGenericClassListed196 § modGenericHandleBare196: an interface home (Surelog publishes an interface's classes at the design root)
interface ifc ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endinterface
module top;
  ifc u ();
endmodule
