// § insideSetParamFoldKeepsPa270
module top #(parameter int P = 4);
  localparam int Q = 6;
  class c;
    function bit f(int w);
      return w inside {P, Q};
    endfunction
  endclass
  c x;
endmodule
