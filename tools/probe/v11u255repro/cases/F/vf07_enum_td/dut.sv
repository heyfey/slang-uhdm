// § fwWinnerListedObject255 (the winner's typedef an enum in a value-parameterised class)
package p;
virtual class vd; endclass
class aa_reg #(int N=2); typedef enum logic [1:0] {A, B, C} this_type; endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user; aa_reg #(3) h; endclass
endpackage
module top; endmodule
