// § unitOobDefsNotInClass402
class pc #(int W = 4);
  extern function int f();
endclass
function int pc::f(); return W; endfunction
module top;
  pc #(8) a = new;
  pc #(16) b = new;
endmodule
