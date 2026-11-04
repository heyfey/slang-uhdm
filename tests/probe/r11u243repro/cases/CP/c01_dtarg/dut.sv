// § clsPropSpecPaNoFile243
// a class in another package holding a generic with a data-type argument and a class argument
package p;
  class gen #(type T = int, type I = int);
    T a;
  endclass
endpackage
package q;
  import p::*;
  class cfg; int z; endclass
  class hold;
    gen#(int, cfg) m;
    static gen#(bit [3:0]) s;
  endclass
endpackage
module top;
  import q::*;
  hold h;
endmodule
