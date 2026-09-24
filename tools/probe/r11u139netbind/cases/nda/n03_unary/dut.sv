module top(input p, output y);
  wire w = ~p;
  assign y = w;
endmodule
