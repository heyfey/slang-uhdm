// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
package q;
  function automatic int f(input int x);
    return x + p::H;
  endfunction
endpackage
module top(output int y);
  assign y = q::f(p::O);
endmodule
