package p;
  class box #(type E = int);
    E v;
  endclass
endpackage
module top;
  p::box #(byte) b;
endmodule
