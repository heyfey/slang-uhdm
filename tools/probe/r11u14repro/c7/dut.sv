// c7 — ARITHMETIC / cast / param-read leftovers, MODULE holder.
package p;
  localparam int unsigned PK = 64;
  typedef struct packed {
    int unsigned x;  // 32 : constant arithmetic
    int unsigned y;  // 32 : param + literal
    int unsigned z;  // 32 : $clog2
    bit          w;  // 1  : bit'(1)
    int unsigned v;  // 32 : whole param read
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.x = 3 * 4;
    r.y = PK + 1;
    r.z = $clog2(64);
    r.w = bit'(1);
    r.v = PK;
    return r;
  endfunction
endpackage

module top();
  localparam p::cfg_t C = p::build();
  child #(.W(C.x)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
