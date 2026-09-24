module top(p, q, y);
  input wire p; input q; output y;
  wire x = p;
  wire z = q;
  assign y = x & z;
endmodule
