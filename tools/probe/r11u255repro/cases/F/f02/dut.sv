// § fwWinnerListedObject255 (five specialisations of the winner class: control)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  aa_reg #(byte, "y") h1;
  aa_reg #(shortint, "z") h2;
  aa_reg #(longint, "w") h3;
  aa_reg #(bit, "v") h4;
  aa_reg #(logic, "u") h5;
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
