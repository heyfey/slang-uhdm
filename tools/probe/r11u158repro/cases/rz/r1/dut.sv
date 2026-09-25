// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; rand bit [3:0] b; constraint c { a < 5; } function void print(); endfunction endclass
module top();
  pkt frame;
  initial begin
    frame = new;
    if (frame.randomize() == 1) begin
      frame.print();
    end
  end
endmodule
