// § patLeftoverOpCopy242
// Operation leftovers of several shapes: a size cast over a wide replication, a wide concatenation without a cast, a size cast of a small literal, one element read by two members.
package cp;
  typedef struct packed {
    int unsigned n;
    logic [3:0][63:0] a;
    logic [127:0] b;
    logic [127:0] c;
  } ucfg_t;
  typedef struct packed {
    int unsigned n;
    logic [3:0][63:0] a;
    logic [127:0] b;
    logic [127:0] c;
    logic [127:0] d;
    bit z;
  } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(3), a: 256'({4{64'h5}}), b: {64'h1, 64'h2}, c: 128'(7)};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.a = u.a;
    r.b = u.b;
    r.c = u.c;
    r.d = u.b;
    r.z = u.n && u.a;
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
