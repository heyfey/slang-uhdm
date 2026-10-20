// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x, y;
  initial begin
    x = new;
    fork
      y = new x;
    join
  end
endmodule
