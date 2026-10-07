// § tfLocalArrRangeDimEnd275 — a ranged local with an initializer
package p;
  function automatic int f(int s);
    int v [0:3] = '{1, 2, 3, 4};
    return v[s];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(1);
endmodule
