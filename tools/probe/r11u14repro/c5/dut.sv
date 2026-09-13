// c5 — REPLICATION leftovers (the kilobit member), MODULE holder.
package p;
  typedef struct packed {
    int unsigned       n;     // 32
    logic [15:0][63:0] wide;  // 1024
    logic [1:0][63:0]  dup;   // 128
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 1;
    r.wide = {16{64'h0}};
    r.dup  = {2{64'hff}};
    return r;
  endfunction
endpackage

module top();
  localparam p::cfg_t C = p::build();
  child #(.W(C.n)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
