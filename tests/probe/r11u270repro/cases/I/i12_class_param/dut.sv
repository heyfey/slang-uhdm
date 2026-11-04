// § insideSetParamFoldKeepsPa270
class C #(int P = 1);
  function bit f(int w);
    return w inside {P, 2};
  endfunction
endclass
module top;
  C #(5) c;
endmodule
