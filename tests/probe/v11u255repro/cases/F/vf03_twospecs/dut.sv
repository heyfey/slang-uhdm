// § fwWinnerListedObject255 (two non-default specialisations of the winner, then the default one)
package p;
virtual class vd; endclass
virtual class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class cc_reg #(type T=int, string N="x") extends aa_reg #(T,N); endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
  function this_type get(); return null; endfunction
endclass
class u1; typedef aa_reg #(u1, "u1") type_id; endclass
class u2; typedef aa_reg #(u2, "u2") type_id; endclass
class u3; cc_reg h; endclass
endpackage
module top; endmodule
