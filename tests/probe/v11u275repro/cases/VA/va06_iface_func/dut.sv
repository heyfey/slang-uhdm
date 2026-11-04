// § tfLocalArrRangeDimEnd275 — an interface function with a ranged local
interface ifc ();
  function automatic int f(int s);
    int v [0:3];
    v[2] = s;
    return v[2];
  endfunction
endinterface
module dut (output int o);
  ifc u ();
  assign o = u.f(5);
endmodule
