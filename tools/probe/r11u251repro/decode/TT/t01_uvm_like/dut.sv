// § oobClassTdFirstClassKey231 (decode only: an in-body formal typed by an inherited this_type; not reproduced)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class mid #(type T=int) extends base #(vd); endclass
class sock #(type T=int) extends mid #(T);
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
