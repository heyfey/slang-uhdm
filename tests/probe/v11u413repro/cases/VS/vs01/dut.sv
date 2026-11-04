// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x;
  initial begin
    C y;
    x = new;
    y = new x;
    y.a = 3;
  end
endmodule
