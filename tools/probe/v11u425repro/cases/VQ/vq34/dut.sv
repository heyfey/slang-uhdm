// § unszPkgFoldElabForm425
package p;
  parameter H = 'd200;
  parameter O = 'o17;
  class C;
    int v = p::H;
    function int g();
      return v + p::O;
    endfunction
  endclass
endpackage
module top;
  initial begin
    p::C c = new;
    void'(c.g());
  end
endmodule
