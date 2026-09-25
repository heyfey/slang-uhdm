// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; endclass
module dut;
  pkt p; int ok;
  initial begin
    p = new;
    ok = p.randomize() with { a < 3; };
    ok = p.randomize( );
    ok = p.randomize (null);
  end
endmodule
