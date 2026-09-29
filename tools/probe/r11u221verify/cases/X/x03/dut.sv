// § genScopeRangeQueryFold216 § opIdxRecvElemFollowsPath215 — a generate scope holding a range-query assignment and a function whose class receiver is indexed by an operation
class fld;
  function int get(); return 0; endfunction
endclass
module dut (input int k, output logic [7:0] o1, output int o2);
  logic [9:4] v;
  fld fs[8];
  for (genvar g = 0; g < 1; g++) begin : gb
    assign o1 = $high(v);
    function automatic int h(int i);
      return fs[i-1].get() + fs[i*2].get();
    endfunction
    always_comb o2 = h(k);
  end
endmodule
