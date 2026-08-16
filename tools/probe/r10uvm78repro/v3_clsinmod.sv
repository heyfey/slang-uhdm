// V3 — a CLASS DECLARED INSIDE A MODULE.  UHDM ComputeFullName sets column=true
// from the class_defn ancestor, so golden joins the WHOLE chain (module joint
// included) with '::' — while joinRef sees a prefix whose first '.' precedes
// any '::' and returns '.'.  Tests the law at a scope kind it never measured.
module v3_clsinmod;
  class inner;
    logic [31:0] cvec;
    int unsigned cq[$];
    function automatic logic [7:0] slice(int b);
      return cvec[b -: 8];
    endfunction
    function automatic int qs(int b);
      int unsigned t[$];
      t = cq[0:b-1];
      return t.size();
    endfunction
    function automatic logic [7:0] idx(int b);
      return cvec[b +: 8];
    endfunction
  endclass
  inner h;
  logic [7:0] r0, r2;
  int r1;
  initial begin
    h = new();
    r0 = h.slice(3);
    r1 = h.qs(2);
    r2 = h.idx(1);
  end
endmodule
