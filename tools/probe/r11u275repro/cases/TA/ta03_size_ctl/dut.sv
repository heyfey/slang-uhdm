// § tfLocalArrRangeDimEnd275 — CONTROL: a size dimension [4] keeps the end before its bracket
package p;
  function automatic int f(int s);
    int v [4];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
