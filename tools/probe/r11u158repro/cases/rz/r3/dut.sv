// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; rand bit [3:0] b; constraint c { a < 5; } function void print(); endfunction endclass
module top();
  pkt o;
  int x;
  initial begin
    o = new;
    x = o.randomize(a);
    x = o.randomize( );
  end
endmodule
