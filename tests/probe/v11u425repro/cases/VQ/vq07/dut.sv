// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  parameter HX = 'h1F;
  parameter B = 'b101;
  parameter Z = 'd0;
  parameter BIG = 'd3000000000;
endpackage
class C;
  int v;
  function void set();
    v = p::H + 1;
    v = v + p::O;
  endfunction
endclass
module top;
  initial begin
    C c = new;
    c.set();
  end
endmodule
