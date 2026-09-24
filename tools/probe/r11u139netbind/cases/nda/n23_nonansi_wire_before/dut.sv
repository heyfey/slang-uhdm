// § ndaLeftmostLeafElab139
module top(p, q, y);
  input p, q; output y;
  wire p, q;
  wire x = p & q;
  assign y = x;
endmodule
