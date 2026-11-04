// § oobClassTdFirstClassKey231 (decode only: as tt01 with a local and an overriding base method; golden binds the first key)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type;
  virtual function void connect(this_type provider); endfunction
endclass
class sock #(type T=int) extends base #(vd);
  function void connect(this_type provider);
    int c;
    c = 1;
  endfunction
endclass
endpackage
module top; endmodule
