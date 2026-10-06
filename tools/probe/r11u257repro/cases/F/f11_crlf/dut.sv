// § fwWinnerSpecTieBreak257 (CRLF source, two specializations)
package p;
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
virtual class vd; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  this_type provider_q;
  function this_type get(); return provider_q; endfunction
endclass
class u1; typedef aa_reg #(u1, "u1") type_id; endclass
class u2; typedef aa_reg #(u2, "u2") type_id; endclass
endpackage
module top; endmodule
