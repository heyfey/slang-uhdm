// § tdKeptParentMemberNames418
module m (input logic a, output o);
  import tp::tag_s;
  tag_s t;
  assign o = t.op;
endmodule
