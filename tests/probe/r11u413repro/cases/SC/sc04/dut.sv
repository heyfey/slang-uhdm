// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x, y, z;
  initial begin
    x = new;
    y = new x;
    z = new y;
  end
endmodule
