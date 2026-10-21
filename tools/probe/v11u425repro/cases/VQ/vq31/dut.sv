// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  function automatic int f(input int x);
    return x + p::H - p::O;
  endfunction
endpackage
module top(output int y);
  assign y = p::f(3);
endmodule
