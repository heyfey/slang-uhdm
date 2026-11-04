// § shallowCopyLhsUnbound413
class C;
  int a;
  C nxt;
  function C dup();
    C r;
    r = new this;
    return r;
  endfunction
endclass
module top;
  C x, y;
  initial begin x = new; y = x.dup(); end
endmodule
