// § oobClassTdFirstClassKey231 (decode only: an in-body formal typed by an inherited this_type; not reproduced)
package p;
class aa_reg #(type T=int); typedef aa_reg #(T) this_type; endclass
class base #(type T=int); typedef base #(T) this_type; endclass
class sock #(type T=int) extends base #(T);
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
