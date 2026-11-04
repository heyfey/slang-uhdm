// § modClassTsLinksDefListing196: a plain module class, two instances of different parameterization (each instance body has its own class symbol)
module sub #(parameter int W = 1) ();
  class plain;
    int v;
  endclass
  plain b;
endmodule
module top;
  sub #(2) v ();
  sub #(3) w ();
endmodule
