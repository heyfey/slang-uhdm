// § fwWinnerSpecTieBreak257 (value parameters whose renderings order differently from their values: -1, 10, 9)
package p;
class aa_reg #(int W=1); typedef aa_reg #(W) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class h1; aa_reg #(10) a; aa_reg #(9) b; aa_reg #(-1) c; endclass
endpackage
module top; endmodule
