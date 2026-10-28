// § tfLocalClassArrElemClassTs452
package p;
  class P #(int N = 4);
    int x;
  endclass
  class R;
    task body;
      P #(8) a[2];
      P b[2];
    endtask
  endclass
endpackage
module top;
endmodule
