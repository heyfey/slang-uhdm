// § portConnOpLeafChain209: a hierarchical reference into a sibling instance inside a connection operation
module leaf (input logic i, output logic q);
  logic sig;
  assign sig = i;
  assign q = sig;
endmodule
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module top (input logic i, input logic t, output logic o, output logic q);
  leaf l (.i(i), .q(q));
  inner u (.b(l.sig & t), .o(o));
endmodule
