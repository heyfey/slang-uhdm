// § elabCloneFullNameUnstored137
module leaf(input logic a, output logic b);
  function automatic logic f(input logic v);
    logic t;
    t = v;
    return t;
  endfunction
  always_comb b = f(a);
endmodule
module mid(input logic a, output logic b);
  leaf l(.a(a), .b(b));
endmodule
module top(input logic x, output logic y);
  mid m(.a(x), .b(y));
endmodule
