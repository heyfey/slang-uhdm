// § methodRandomizeCallSpan158
class inner; rand bit [3:0] a; endclass
class outer; inner i; function new(); i = new; endfunction
  function void f(); void'(this.i.randomize()); void'(i.randomize()); endfunction
endclass
module dut; outer o; initial begin o = new; o.f(); end endmodule
