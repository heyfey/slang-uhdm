// § elabAssocVecIdxRange452
module top;
  function automatic int f();
    int m[logic[7:0]];
    m[1] = 3;
    return m[1];
  endfunction
  initial $display(f());
endmodule
