module top(p, q, y);
  input p, q; output y;
  wire x = p;
  wire p;
  assign y = x & q;
endmodule
