// § modGenericClassListed196 § modClassTsLinksDefListing196: a generic whose default comes from the module parameter, one definition under two parameterizations
module sub #(parameter int P = 4) ();
  class vec #(int W = P);
    logic [W-1:0] d;
  endclass
  vec a;
  vec #(P*2) b;
endmodule
module top;
  sub #(.P(4)) u1 ();
  sub #(.P(8)) u2 ();
endmodule
