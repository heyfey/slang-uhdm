// § timeModVarIsNet406
module top;
  function void f();
    static time t;
    t = 3;
  endfunction
  initial begin : b
    time w;
    w = 1;
    f();
  end
endmodule
