// § tfLocalClassArrElemClassTs452
package p;
  interface class IC;
    pure virtual function void f();
  endclass
  class R;
    task body;
      IC a[2];
    endtask
  endclass
endpackage
module top;
endmodule
