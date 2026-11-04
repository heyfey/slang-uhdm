// § tfLocalClassArrElemClassTs452
package p;
  class B;
    int x;
  endclass
  class R;
    task body;
      B seq_array[4];
      seq_array[0] = new;
    endtask
  endclass
endpackage
module top;
endmodule
