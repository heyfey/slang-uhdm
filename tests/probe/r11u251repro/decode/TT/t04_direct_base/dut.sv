// § oobClassTdFirstClassKey231 (decode only: an in-body formal typed by an inherited this_type; not reproduced)
package p;
virtual class vd; endclass
class aa_reg #(type T=int); typedef aa_reg #(T) this_type; endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sock #(type T=int) extends base #(vd);
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
