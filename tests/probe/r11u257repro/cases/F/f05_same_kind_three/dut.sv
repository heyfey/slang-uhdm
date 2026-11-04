// § fwWinnerSpecTieBreak257 (three specializations of the winner, same kind, the default never written)
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
class u1; aa_reg #(u1, 2) h1; endclass
class u2; aa_reg #(u2, 3) h2; endclass
class u3; aa_reg #(u3, 4) h3; endclass
endpackage
module top; endmodule
