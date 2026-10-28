// § vsTrailRangeColonJoin453
module top;
  class C;
    logic [3:0][7:0] m;
    function void f(int i0);
      m[i0][i0+:2] = 1;
    endfunction
  endclass
endmodule
