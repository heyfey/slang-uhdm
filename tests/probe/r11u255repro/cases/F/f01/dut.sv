// § fwWinnerListedObject255 (the decode case of pass 253 with one specialisation: control)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  aa_reg #(byte, "y") h;
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
