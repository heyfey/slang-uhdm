// § vsTrailRangeColonJoin453
interface ifc;
  function automatic void f(int i0);
    logic [3:0][7:0] m;
    m[i0][i0+:2] = 1;
  endfunction
endinterface
module top;
  ifc u();
endmodule
