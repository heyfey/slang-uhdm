// § fwWinnerSpecTieBreak257 (two generic classes declare the name; the alphabetically first with only non-default specializations)
package p;
class aa_reg #(type T=int); typedef aa_reg #(T) this_type; endclass
class ab_reg #(type T=int); typedef ab_reg #(T) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class u1; aa_reg #(u1) h1; aa_reg #(byte) h2; ab_reg #(u1) h3; endclass
endpackage
module top; endmodule
