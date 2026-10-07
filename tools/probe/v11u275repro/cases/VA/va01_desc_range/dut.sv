// § tfLocalArrRangeDimEnd275 — a descending ranged local array
package p;
  function automatic int f(int s);
    int v [3:0];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
