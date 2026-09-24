// c4 — c3's CONCAT shapes with a PACKAGE holder.
package p;
  typedef struct packed {
    int unsigned      n;
    logic [2:0][63:0] base;
    logic [63:0]      part;
    logic [31:0]      narrow;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n      = 2;
    r.base   = {64'h0, 64'h0000_8000, 64'h0000_1000};
    r.part   = {32'h1, 32'h2};
    r.narrow = {8'h1, 8'h2};
    return r;
  endfunction
  localparam cfg_t C = build();
endpackage

module top();
  child #(.W(p::C.n)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
