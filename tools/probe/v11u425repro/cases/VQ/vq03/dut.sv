// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output int y, output int z);
  function automatic int f(input int x);
    return x + p::O;
  endfunction
  function automatic int g();
    return p::H;
  endfunction
  assign y = f(p::H);
  assign z = g();
endmodule
