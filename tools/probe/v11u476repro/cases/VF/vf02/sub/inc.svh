module m;
  int x;
  initial begin $display("%s %d", `__FILE__, `__LINE__); x = 2; end
endmodule
