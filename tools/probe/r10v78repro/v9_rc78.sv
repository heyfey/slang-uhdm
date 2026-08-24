// r10v78 arm v9 - the rc PROBE: an "unsupported construct" INSIDE a gen-scope
// replication that the fold removes.  slang-uhdm reports unsupported
// constructs with rc=4; folding the whole Rhs can suppress that report.
module v9;
  localparam int N = 3;
  function automatic logic [3:0] f9(input int a);
    return a[3:0];
  endfunction
  logic [15:0] r_a;
  if (N > 0) begin : g9
    assign r_a = {N{f9(1)[0]}};
  end
endmodule
