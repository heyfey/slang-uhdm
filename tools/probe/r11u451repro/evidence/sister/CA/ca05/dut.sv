// sister-ground face (TaskFuncEmit): a subroutine-body class-array local's element typespec
class B;
  int x;
endclass
module top;
  initial begin
    B arr[3];
    B m[2][2];
    arr[0] = new;
  end
endmodule
