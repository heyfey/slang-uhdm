// § opIdxRecvElemFollowsPath215 — deep receivers with operation indexes inside an interface function and a module task
class fld;
  function int get(); return 0; endfunction
endclass
interface ifc;
  fld fs[$];
  function automatic int f(int i);
    return fs[i-1].get();
  endfunction
endinterface
module m(input int k, output int o);
  ifc u();
  fld gs[$];
  task automatic t(input int i, output int r);
    r = gs[i+1].get();
  endtask
  always_comb begin
    int r;
    t(k, r);
    o = r + u.f(k);
  end
endmodule
