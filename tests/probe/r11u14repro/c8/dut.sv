// c8 — c7's ARITHMETIC shapes with a PACKAGE holder.
package p;
  localparam int unsigned PK = 64;
  typedef struct packed {
    int unsigned x;
    int unsigned y;
    int unsigned z;
    bit          w;
    int unsigned v;
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
  localparam cfg_t C = build();
endpackage

module top();
  child #(.W(p::C.x)) u1();
endmodule

module child #(parameter int unsigned W = 1) (); endmodule
