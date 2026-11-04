// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x;
  initial begin
    x = new;
    begin
      C z = new x;
      z.a = 1;
    end
  end
endmodule
