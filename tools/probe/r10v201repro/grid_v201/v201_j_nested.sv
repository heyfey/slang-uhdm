// v201 arm J — a SUBMODULE that imports too, and a parameter PORT LIST on
// the importer (defImpElabShape9's flip).
package p201vj;
  parameter J_A = 13;
  parameter J_B = J_A;
endpackage
import p201vj::*;
module sub201vj;
  import p201vj::*;
endmodule
module m201vj #(parameter P = 4) ;
  sub201vj u_sub();
endmodule
