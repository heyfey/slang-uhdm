module sub ();
  class box #(type E = int);
    E v;
  endclass
  box #(byte) b;
endmodule
module top;
  sub v ();
endmodule
