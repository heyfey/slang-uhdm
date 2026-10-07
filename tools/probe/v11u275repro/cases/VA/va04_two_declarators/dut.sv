// § tfLocalArrRangeDimEnd275 — two declarators, ranged and sized
package p;
  function automatic int f(int s);
    int a [0:3], b [4];
    a[0] = s;
    b[0] = a[0];
    return b[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
