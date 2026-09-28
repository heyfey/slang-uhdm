// § evalFuncCastMemberKeepsCall191: a cast to a type parameter, a cast inside a branch, and a cast to a bit typedef (folds)
module top #(parameter type T = logic [3:0]) (output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3);
  typedef bit [3:0] b_t;
  function automatic logic [3:0] f(input int a); return T'(a); endfunction
  function automatic logic [3:0] g(input int a); if (a > 100) return 4'(a); return a[3:0]; endfunction
  function automatic logic [3:0] h(input int a); return b_t'(a); endfunction
  assign o1 = f(3);
  assign o2 = g(5);
  assign o3 = h(6);
endmodule
