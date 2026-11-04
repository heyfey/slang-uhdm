// § fwWinnerSpecTieBreak257 (string-parameter specializations)
package p;
class aa_reg #(string N="x"); typedef aa_reg #(N) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class u1; aa_reg #("a") h1; aa_reg #("b") h2; aa_reg #("c") h3; endclass
endpackage
module top; endmodule
