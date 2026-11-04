// § tfLocalArrRangeDimEnd275 — two ranged dimensions, the last one ends the span
package p;
  function automatic int f(int s);
    int v [0:1][0:3];
    v[0][1] = s;
    return v[0][1];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
