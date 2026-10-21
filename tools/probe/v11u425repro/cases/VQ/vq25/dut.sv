// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
module top(output int y);
  function automatic int f();
    int s = 0;
    for (int i = 0; i < p::O; i++) s += i;
    return s;
  endfunction
  assign y = f();
endmodule
