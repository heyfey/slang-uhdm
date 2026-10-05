// § evalFuncPkgStructMemberFolds237
// the member read in the gen-scope flavour
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t S = '{5, 6};
  function automatic int unsigned fw(int unsigned i);
    return S.e + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  if (1) begin : g
    assign o = q::fw(3);
  end
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
