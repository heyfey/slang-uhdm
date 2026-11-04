// § vsTrailRangeColonJoin453
interface ifc;
  logic [3:0][7:0] m;
  function automatic void f(int i0);
    m[i0][i0+:2] = 1;
  endfunction
endinterface
module top;
  ifc u();
endmodule
