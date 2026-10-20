// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x;
  C arr[2];
  initial begin x = new; arr[0] = new x; end
endmodule
