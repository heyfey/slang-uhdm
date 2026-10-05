// § evalFuncPkgParamVarSelKeepsCall237
// nested call, no if
package q;
  function automatic int unsigned fw(int unsigned i);
    return i + 1;
  endfunction
  function automatic int unsigned maxw(int unsigned n);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < n; i++)
      res = res + fw(i);
    return res;
  endfunction
endpackage
module sub #(parameter int unsigned M = 1) (output logic [31:0] o);
  assign o = q::maxw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(3)) u (.o(o));
endmodule
