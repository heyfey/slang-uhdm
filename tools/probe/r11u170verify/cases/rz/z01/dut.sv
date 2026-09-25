// § methodRandomizeCallSpan158
class inner; rand int x; endclass
class outer; inner in1; function new(); in1 = new; endfunction endclass
module top;
  outer o; int ok;
  initial begin o = new; ok = o.in1.randomize(); end
endmodule
