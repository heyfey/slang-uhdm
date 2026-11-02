// § clsMethodOwnAutomatic462
package p;
  class C;
    extern task t();
  endclass
  task automatic C::t();
  endtask
endpackage
package q;
  import p::*;
  class D extends C;
  endclass
endpackage
module top;
  import q::*;
  D d;
endmodule
