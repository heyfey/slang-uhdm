// § fixedClassPropIsArrayVar6 (site of the residue: the class-property array arm; decode only, no law of r11u249)
package p;
  typedef bit [3:0] v_t;
  class q;
    v_t dq[][$];
  endclass
endpackage
module top;
  import p::*;
  q x;
endmodule
