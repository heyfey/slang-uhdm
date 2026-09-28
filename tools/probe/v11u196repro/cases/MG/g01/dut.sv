// § modGenericClassListed196 § modClassTsLinksDefListing196: a parameterized class in a generate FOR loop of the home, two instances of different parameterization
module sub #(parameter int W = 1) ();
  for (genvar i = 0; i < 2; i++) begin : g
    class box #(type E = int);
      E v;
    endclass
    box #(byte) b;
  end
endmodule
module top;
  sub #(2) v ();
  sub #(3) w ();
endmodule
