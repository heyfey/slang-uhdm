// v13 — indices that are CALLS, package-qualified names, and $-system calls,
// mixed with a genvar: the genvar-detector walks the SYNTAX by NAME, so these
// are the shapes where a name lookup can go wrong.
package pk;
  parameter int P = 5;
  function automatic int twice(input int x); return 2*x; endfunction
endpackage
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top #(parameter int P = 3) (input logic [63:0] arr);
  sif sarr [0:63] ();
  function automatic int dbl(input int x); return 2*x; endfunction
  genvar i;
  for (i = 0; i < 2; ++i) begin : g
    ileaf a (.s (sarr[dbl(i)]));
    ileaf b (.s (sarr[pk::twice(i)]));
    ileaf c (.s (sarr[pk::P + i]));
    ileaf d (.s (sarr[P + i]));
    ileaf e (.s (sarr[dbl(i) + 1]));
    ileaf f (.s (sarr[$clog2(4) + i]));
    nleaf n0 (.p (arr[dbl(i)]));
    nleaf n1 (.p (arr[pk::P + i]));
    nleaf n2 (.p (arr[$clog2(4) + i]));
  end
endmodule
