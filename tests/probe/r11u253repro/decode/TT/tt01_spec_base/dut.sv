// § oobClassTdFirstClassKey231 (decode only: an in-body formal typed by an inherited this_type binds the first-key class typedef in golden; not the BuildUVMPkg face)
package p;
virtual class vd; endclass
class aa_reg #(type T=int, string N="x"); typedef aa_reg #(T,N) this_type; endclass
class tif #(type T=int, type P=int); endclass
virtual class base #(type IF=vd) extends IF; typedef base #(IF) this_type; endclass
class sb #(type T=int) extends base #(tif #(T)); endclass
class sock #(type T=int) extends sb #(T);
  function void connect(this_type provider); endfunction
endclass
endpackage
module top; endmodule
