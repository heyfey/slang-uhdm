// § evalFuncPkgParamVarSelKeepsCall237
// the cfg_func_width_loop shape
package q;
  localparam int unsigned NF = 3;
  typedef logic [0:NF-1] mask_t;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t [0:NF-1] ENC = '{'{4, 3}, '{3, 2}, '{2, 1}};
  function automatic int unsigned fwidth(int unsigned i);
    return unsigned'(2 ** (ENC[i].e - 1) - 1) + ENC[i].m;
  endfunction
  function automatic int unsigned maxw(mask_t cfg);
    automatic int unsigned res = 0;
    for (int unsigned i = 0; i < NF; i++)
      if (cfg[i])
        if (fwidth(i) > res) res = fwidth(i);
    return res;
  endfunction
endpackage
module sub #(parameter q::mask_t M = '0) (output logic [31:0] o);
  assign o = q::maxw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(3'b101)) u (.o(o));
endmodule
