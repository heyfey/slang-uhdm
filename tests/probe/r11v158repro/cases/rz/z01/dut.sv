// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; endclass
module dut;
  pkt p;
  initial begin
    p = new;
    assert(p.randomize());
    if (!p.randomize()) $display("x");
    void'(p.randomize());
  end
endmodule
