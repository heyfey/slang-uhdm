// § fwWinnerListedObject255 (a module variable of the non-default specialisation and of the socket)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; this_type nxt; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
endpackage
module top;
  p::aa_reg #(byte, "b") r;
  p::sock #(int) s;
endmodule
