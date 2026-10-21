// § unszBasedPkgFoldUnsized423 (control: a module parameter, not reached)
module top(input int x, output int y);
  parameter R = 'hf000000;
  function int f(int a);
    return a & R;
  endfunction
  assign y = f(x) & R;
endmodule
