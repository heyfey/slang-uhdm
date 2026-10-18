// § elabMosPullPrims402
module child(output o, input i, c);
  pmos m1 (o, i, c);
  pullup (o);
endmodule
module top(output o1, o2, input i, c);
  child u1(o1, i, c);
  child u2(o2, i, c);
endmodule
