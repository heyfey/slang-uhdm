// sister-ground face (TaskFuncEmit): a subroutine-body class-array local's element typespec
package p;
  class B;
    int x;
  endclass
  class R;
    task body;
      B h;
      B arr[2];
      B q[$];
      B d[];
      h = arr[0];
    endtask
  endclass
endpackage
module top;
endmodule
