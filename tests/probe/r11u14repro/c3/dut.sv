// c3 — CONCAT leftover shapes, MODULE holder.  `narrow` is the csize
// distinguisher: its concat operands sum to LESS than the member's width.
package p;
  typedef struct packed {
    int unsigned      n;      // 32
    logic [2:0][63:0] base;   // 192, concat sums 192
    logic [63:0]      part;   // 64,  concat sums 64
    logic [31:0]      narrow; // 32,  concat sums 16
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n      = 2;
    r.base   = {64'h0, 64'h0000_8000, 64'h0000_1000};
    r.part   = {32'h1, 32'h2};
    r.narrow = {8'h1, 8'h2};
    return r;
  endfunction
endpackage

module top();
  localparam p::cfg_t C = p::build();
  child #(.W(C.n)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
