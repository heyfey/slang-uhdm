// r10uvm100 arm a6 -- the CORPUS shapes, verbatim in spirit: Yosys
// svinterfaces' bare `#(2);` statement delay, and a `#(<call>)` delay.
module m6a;
  reg clk6;
  integer n6;
  function automatic integer f6(input integer k);
    f6 = k + 1;
  endfunction
  initial begin
    clk6 = 0;
    #(2);
    clk6 = 1;
    #(2)
    clk6 = 0;
    #(f6(1));
    n6 = 1;
  end
endmodule
