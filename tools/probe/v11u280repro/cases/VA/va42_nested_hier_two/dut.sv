// § hpMemVarSelRvalSpan280 § hpMemVarSelIdxNamesByChain280 § hpMemVarSelNamesFinal280
// a three-member path with two selects at the end under an if-generate inside a for-generate, in a function call argument
module top(input logic [1:0] k, output logic [1:0] o);
  typedef struct packed { logic [3:0][1:0] g; logic b; } s_t;
  typedef struct packed { s_t s; logic c; } t_t;
  typedef struct packed { t_t t; logic d; } u_t;
  u_t w;
  assign w = '0;
  function automatic logic inv(logic a); return ~a; endfunction
  for (genvar i = 0; i < 2; i++) begin : ga
    if (i >= 0) begin : gi
      assign o[i] = inv(w.t.s.g[k][i]);
    end
  end
endmodule
