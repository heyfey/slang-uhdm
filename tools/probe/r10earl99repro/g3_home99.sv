// r10earl99 g3 -- HOMES.  The same ternary-arm pattern in a module, a
// submodule instantiated THREE TIMES, a generate scope, and reached through a
// package function's return type.
package t99;
  typedef struct packed {
    logic [2:0] a;
    logic [4:0] b;
  } s_t;
  function automatic s_t mk99(input logic [2:0] x);
    mk99 = '{a: x, b: '1};
  endfunction
endpackage

module leaf99 #(parameter int W = 5) (
  input  logic    sel,
  input  t99::s_t d,
  output t99::s_t o
);
  assign o = sel ? d : '{a: '1, b: '0};
endmodule

module g3_home99 (
  input  logic     sel,
  input  t99::s_t  d,
  output t99::s_t  o_top,
  output t99::s_t  o_i0,
  output t99::s_t  o_i1,
  output t99::s_t  o_i2,
  output t99::s_t  o_gen,
  output t99::s_t  o_fun
);
  assign o_top = sel ? d : '{a: '1, b: '0};
  assign o_fun = sel ? d : t99::mk99(3'b101);

  leaf99 u0 (.sel(sel), .d(d), .o(o_i0));
  leaf99 u1 (.sel(sel), .d(d), .o(o_i1));
  leaf99 u2 (.sel(sel), .d(d), .o(o_i2));

  genvar gi;
  generate
    for (gi = 0; gi < 1; gi++) begin : g_blk
      t99::s_t inner;
      assign inner = sel ? d : '{a: '1, b: '0};
      assign o_gen = inner;
    end
  endgenerate
endmodule
