// § methodRandomizeCallSpan158
class pkt; rand int x; endclass
module top;
  pkt p; int ok; int ok2;
  initial begin
    p = new;
    ok = p.randomize ();
    ok2 = p.randomize(
    );
  end
endmodule
