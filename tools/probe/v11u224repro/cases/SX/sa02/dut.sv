// § strLitPpEscIdShift224
package p;
  class c #(int W = 1);
    string s = "a\nb` c"; int k = W;
  endclass
  typedef c#(2) c2_t;
endpackage
module top(output string o);
  p::c2_t h;
  initial begin h = new; o = h.s; end
endmodule
