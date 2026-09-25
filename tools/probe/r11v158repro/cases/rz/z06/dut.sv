// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; endclass
module dut;
  pkt p; bit ok;
  initial begin
    p = new;
    ok = p.randomize() && 1;
    ok = (p.randomize());
    repeat (2) assert (p.randomize()) else $error("x");
  end
endmodule
