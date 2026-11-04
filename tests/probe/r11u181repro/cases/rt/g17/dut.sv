// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path inside a class method
module top; logic [3:0] v; sub u(); endmodule
module sub;
  class C; logic [3:0] w; function void f(); w = $root.top.v; endfunction endclass
  initial begin C c = new; c.f(); end
endmodule
