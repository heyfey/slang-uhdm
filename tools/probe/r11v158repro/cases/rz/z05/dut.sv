// § methodRandomizeCallSpan158
class base; rand bit [3:0] a; endclass
class pkt extends base; rand bit [3:0] b;
  function int f(); int ok; ok = this.randomize(); ok = super.randomize(); return ok; endfunction
endclass
module dut; pkt p; initial begin p = new; void'(p.f()); end endmodule
