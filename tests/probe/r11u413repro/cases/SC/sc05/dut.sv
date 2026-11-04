// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x, y;
  initial begin
    x = new;
    y = x;
  end
endmodule
