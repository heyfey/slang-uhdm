// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; rand bit [3:0] b; constraint c { a < 5; } function void print(); endfunction endclass
class holder; pkt p; function new(); p = new; endfunction endclass
module top();
  holder h;
  int x;
  initial begin
    h = new;
    x = h.p.randomize();
  end
endmodule
