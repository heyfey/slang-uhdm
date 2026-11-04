// § fwWinnerSpecTieBreak257 (two specializations whose type arguments are same-named classes of two packages)
package q; class u1; endclass endpackage
package r; class u1; endclass endpackage
package p;
class aa_reg #(type T=int, int W=1); typedef aa_reg #(T, W) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class h1; aa_reg #(q::u1, 2) a; endclass
class h2; aa_reg #(r::u1, 2) b; endclass
endpackage
module top; endmodule
