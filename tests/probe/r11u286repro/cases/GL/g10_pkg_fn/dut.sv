// § genProcLvIdxCallSpan286 — package function call and system call as lvalue index
package pk;
  function automatic int pf(input int x); return x; endfunction
endpackage
module dut ();
  logic [7:0] w;
  logic [7:0] z;
  for (genvar f = 0; f < 1; f++) begin : gf
    always_comb begin
      w[pk::pf(2)] = 1'b1;
      z[$clog2(4)] = 1'b1;
    end
  end
endmodule
