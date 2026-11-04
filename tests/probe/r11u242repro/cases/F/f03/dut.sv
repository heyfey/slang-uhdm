// § patLeftoverOpCopy242
// Controls beside the law: a cast concatenation that fits 64 bits (folds to a constant), a
// replication member, an unsized literal member; one wide cast member read whole.
package cp;
  typedef struct packed {
    logic [3:0][63:0] w;
    logic [3:0][63:0] s;
    logic [3:0][63:0] r;
    int unsigned k;
  } cfg_t;
endpackage
package up;
  localparam cp::cfg_t U = '{
    w: 256'({64'h1, 64'h2}),
    s: 256'({64'h8000_0000}),
    r: {4{64'h0}},
    k: 9
  };
endpackage
package bp;
  function automatic cp::cfg_t build(cp::cfg_t c);
    cp::cfg_t q;
    q.w = c.w;
    q.s = c.s;
    q.r = c.r;
    q.k = c.k && c.w;
    return q;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = bp::build(up::U)) (output logic o);
  assign o = 1'b0;
endmodule
