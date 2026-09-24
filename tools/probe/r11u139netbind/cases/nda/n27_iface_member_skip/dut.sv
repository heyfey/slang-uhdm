module top(input p, input q, output y);
  wire a = p, b = q & p;
  assign y = a ^ b;
endmodule
