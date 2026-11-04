// § fwWinnerListedObject255 (a scalar typedef name: my_t of a specialised generic class)
package p;
virtual class vd; endclass
virtual class aa_reg #(type T=int, string N="x"); typedef bit [3:0] my_t; endclass
class cc_reg #(type T=int, string N="x") extends aa_reg #(T,N); endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef int my_t; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(my_t provider); endfunction
endclass
class a0user;
  cc_reg #(byte, "y") h1;
endclass
endpackage
module top; endmodule
