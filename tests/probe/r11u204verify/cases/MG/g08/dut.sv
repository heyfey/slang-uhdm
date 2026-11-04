// § modGenericClassListed196 § modClassTsLinksDefListing196: two definitions each declaring a generic class named box, each instantiated twice
module sa ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endmodule
module sb ();
  class box #(int W = 3);
    logic [W-1:0] v;
  endclass
  box #(5) b;
endmodule
module top;
  sa a1 ();
  sa a2 ();
  sb b1 ();
  sb b2 ();
endmodule
