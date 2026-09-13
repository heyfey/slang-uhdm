// c6 — c5's REPLICATION shapes with a PACKAGE holder.
package p;
  typedef struct packed {
    int unsigned       n;
    logic [15:0][63:0] wide;
    logic [1:0][63:0]  dup;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 1;
    r.wide = {16{64'h0}};
    r.dup  = {2{64'hff}};
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage

module top();
  child #(.W(p::C.n)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
