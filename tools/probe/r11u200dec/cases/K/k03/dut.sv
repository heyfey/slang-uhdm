module top;
  class box #(type E = int);
    E v;
  endclass
  initial begin
    box #(byte) b;
    b = new;
  end
endmodule
