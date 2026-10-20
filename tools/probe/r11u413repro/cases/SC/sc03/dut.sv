// § shallowCopyLhsUnbound413
class C;
  int a;
endclass
module top;
  C x;
  function automatic C cp(C src);
    C r;
    r = new src;
    return r;
  endfunction
  initial begin x = new; x = cp(x); end
endmodule
