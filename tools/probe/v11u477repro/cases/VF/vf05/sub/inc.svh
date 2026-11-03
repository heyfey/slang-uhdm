module m;
  string s;
  initial begin s = {`__FILE__, ":x"}; $display(s); end
endmodule
