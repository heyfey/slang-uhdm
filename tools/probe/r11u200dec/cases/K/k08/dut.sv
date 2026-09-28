module top;
  class box #(type E = int, int N = 2);
    E v[N];
  endclass
  box #(byte, 3) b;
  box #(shortint) c;
endmodule
