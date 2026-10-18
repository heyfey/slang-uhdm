// § elabMosPullPrims402
module top;
  wire w, v;
  pullup (strong1) p1 (w);
  pulldown (weak0) p2 (v);
endmodule
