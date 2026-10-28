// sister-ground face (TaskFuncEmit): a subroutine-body class-array local's element typespec
package p;
  class B;
    int x;
  endclass
  class R;
    task body;
      B seq_array[4];
      foreach (seq_array[i]) begin
        seq_array[i].x = i;
      end
    endtask
  endclass
endpackage
module top;
endmodule
