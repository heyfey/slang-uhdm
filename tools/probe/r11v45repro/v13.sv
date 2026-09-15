// v13 — the chain source is OVERRIDDEN with a PACKAGE STRUCT typedef and the
// chained name types the ports (the CVA6 pass-through shape).
package pk;
  typedef struct packed { logic [7:0] d; logic e; } s_t;
endpackage
module child #(
    parameter type base_t = logic,
    parameter type use_t  = base_t
) ( input use_t i, output use_t o );
  assign o = i;
endmodule
module dut ( input pk::s_t i, output pk::s_t o );
  child #(.base_t(pk::s_t)) u ( .i(i), .o(o) );
endmodule
