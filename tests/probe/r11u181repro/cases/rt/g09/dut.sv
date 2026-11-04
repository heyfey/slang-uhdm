// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root read returned by a module function
module top; int i; sub u(); endmodule
module sub; int w; function automatic int f2(); return $root.top.i; endfunction initial w = f2(); endmodule
