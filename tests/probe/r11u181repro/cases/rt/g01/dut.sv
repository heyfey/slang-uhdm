// § rootPathFullNameByChain181 — a $root path as a system function argument (CovMacro's shape)
module DUT; endmodule
module top; int unsigned i; DUT unit1();
  initial begin
    i = $coverage_control(1, 2, 3, $root.top);
    i = $coverage_control(1, 2, 3, $root.top.unit1);
  end
endmodule
