// § tfLocalArrRangeDimEnd275 — a size dimension followed by a ranged one
package p;
  function automatic int f(int s);
    int v [2][0:3];
    v[1][0] = s;
    return v[1][0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
