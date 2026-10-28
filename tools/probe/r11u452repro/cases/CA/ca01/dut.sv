// § tfLocalClassArrElemClassTs452
package p;
  class B;
    int x;
  endclass
  class R;
    task body;
      B seq_array[4];
      seq_array.shuffle();
      foreach (seq_array[i]) begin
        seq_array[i].x = i;
      end
    endtask
  endclass
endpackage
module top;
endmodule
