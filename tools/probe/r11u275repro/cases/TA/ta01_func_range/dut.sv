// § tfLocalArrRangeDimEnd275 — a ranged unpacked local in a package function
package p;
  function automatic int f(int s);
    int v [0:3];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
