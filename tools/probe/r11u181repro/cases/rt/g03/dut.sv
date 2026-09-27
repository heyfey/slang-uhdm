// § rootPathFullNameByChain181 § rootNetPathOwnNames181 — a $root path as a user function argument
module top; logic [3:0] v; sub u(); endmodule
module sub; logic [3:0] w;
  function automatic logic [3:0] f(logic [3:0] a); return a; endfunction
  initial w = f($root.top.v);
endmodule
