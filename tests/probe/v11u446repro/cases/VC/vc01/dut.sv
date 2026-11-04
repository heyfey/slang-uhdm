// § clsBodyCallBindsHomeTopTf446
package p;
  task automatic tk(input int v, output int o);
    o = v + 1;
  endtask
endpackage
package q;
  import p::*;
  class C;
    task run(int a);
      int b;
      tk(a, b);
    endtask
  endclass
endpackage
module top;
  import q::*;
  C c;
endmodule
