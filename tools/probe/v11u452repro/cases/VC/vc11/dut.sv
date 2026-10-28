// § tfLocalClassArrElemClassTs452
package p;
  class C;
    int x;
  endclass
  class R;
    task body;
      C a[2], b[3];
      C c;
    endtask
  endclass
endpackage
package q;
  import p::*;
  class S extends R;
    int y;
  endclass
endpackage
module top;
  import q::*;
endmodule
