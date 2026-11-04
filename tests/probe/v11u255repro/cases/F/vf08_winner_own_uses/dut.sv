// § fwWinnerListedObject255 (the winner class's own members typed by its this_type, non-default specialisation first)
package p;
virtual class vd; endclass
virtual class aa_reg #(type T=int, string N="x");
  typedef aa_reg #(T,N) this_type;
  static this_type me;
  static function this_type get(); this_type t; t = me; return t; endfunction
endclass
class tif #(type T=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
class user; typedef aa_reg #(user, "user") type_id; endclass
endpackage
module top; endmodule
