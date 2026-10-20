// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x, y;
  task automatic cp();
    y = new x;
  endtask
  initial begin x = new; cp(); end
endmodule
