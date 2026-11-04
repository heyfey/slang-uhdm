// sister-ground face (TaskFuncEmit): a subroutine-body class-array local's element typespec
package p;
  class B;
    int x;
  endclass
  class R;
    task body;
      begin
        B arr[2];
        arr[0] = new;
      end
    endtask
  endclass
endpackage
module top;
endmodule
