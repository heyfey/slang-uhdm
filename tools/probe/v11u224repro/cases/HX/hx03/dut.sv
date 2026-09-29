// § hpLvNewClassFirstElemSpan224
package p;
  class s; int x; endclass
  class r; s parent; endclass
  r g = new;
endpackage
module top(output int o);
  initial begin
    p::g.parent = new;
    o = p::g.parent.x;
  end
endmodule
