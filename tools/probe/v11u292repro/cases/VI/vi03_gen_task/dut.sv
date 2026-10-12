// § clsScopedChainIdxDirect292
package p;
  class b; int hval; static b stat = new(); endclass
  typedef struct packed { logic [2:0] f; } s_t;
  s_t pv;
endpackage
module top;
  logic [7:0] a;
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] q;
    always_comb q[g] = a[p::pv.f];
  end
  task automatic t(output logic o); o = a[p::b::stat.hval]; endtask
  function automatic logic ff(); return a[p::pv.f]; endfunction
  always_comb a[p::pv.f] = 1'b1;
endmodule
