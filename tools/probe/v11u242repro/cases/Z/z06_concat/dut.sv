// § patLeftoverOpCopy242
// A wide concatenation without a cast and a size cast of a small literal as leftovers, one element read by two members.
package cp;
  typedef struct packed { int unsigned n; logic [127:0] b; logic [127:0] c; } ucfg_t;
  typedef struct packed { int unsigned n; logic [127:0] b; logic [127:0] c; logic [127:0] d; bit z; } cfg_t;
  localparam ucfg_t U = '{n: unsigned'(3), b: {64'h1, 64'h2}, c: 128'(7)};
  function automatic cfg_t build(ucfg_t u);
    cfg_t r;
    r.n = u.n;
    r.b = u.b;
    r.c = u.c;
    r.d = u.b;
    r.z = u.n && u.b;
    return r;
  endfunction
endpackage
module top #(parameter cp::cfg_t C = cp::build(cp::U)) (output logic o);
  assign o = 1'b0;
endmodule
