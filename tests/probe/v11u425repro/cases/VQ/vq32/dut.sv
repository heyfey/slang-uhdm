// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
endpackage
function automatic int uf(input int x);
  return x * p::H + p::O;
endfunction
module top(output int y);
  assign y = uf(2);
endmodule
