// § modClassTsLinksDefListing196: two generate blocks of one home each declaring a class of the same name, two instances of different parameterization
module sub #(parameter int W = 1) ();
  if (1) begin : g1
    class c;
      int a;
    endclass
    c h1;
  end
  if (1) begin : g2
    class c;
      byte b;
    endclass
    c h2;
  end
endmodule
module top;
  sub #(2) v ();
  sub #(3) w ();
endmodule
