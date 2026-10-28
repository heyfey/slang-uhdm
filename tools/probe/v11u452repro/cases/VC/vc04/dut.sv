// § tfLocalClassArrElemClassTs452
package p;
  class C;
    int x;
  endclass
endpackage
package q;
  class R;
    task body;
      p::C a[2];
    endtask
  endclass
endpackage
module top;
endmodule
