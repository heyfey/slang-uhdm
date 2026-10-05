// § evalFuncPkgParamVarSelKeepsCall237
// bit-select of the formal in an if, no nested call
package q;
  typedef logic [0:2] mask_t;
  function automatic int unsigned maxw(mask_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < 3; i++)
      if (cfg[i]) res = res + i;
    return res;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [31:0] o);
  assign o = q::maxw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
