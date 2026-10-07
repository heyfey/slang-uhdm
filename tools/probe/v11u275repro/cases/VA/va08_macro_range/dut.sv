// § tfLocalArrRangeDimEnd275 — a range written by a macro
`define R [0:3]
package p;
  function automatic int f(int s);
    int v `R;
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
