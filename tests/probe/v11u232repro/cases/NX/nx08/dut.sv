// § structCopyNestedAnnotDeep232
package p;
  typedef struct packed {
    int unsigned a;
    bit flag1;
    bit flag2;
  } ucfg_t;
  typedef struct packed {
    ucfg_t u;
    int unsigned d;
  } cfg_t;
  function automatic ucfg_t setcfg();
    ucfg_t c;
    c.a = 7;
    c.flag1 = 1'b1;
    c.flag2 = 1'b0;
    return c;
  endfunction
  function automatic cfg_t build(input ucfg_t u);
    cfg_t r;
    r.u = u;
    r.d = u.a * 2;
    return r;
  endfunction
  localparam ucfg_t U = setcfg();
  localparam cfg_t C = build(U);
endpackage
// the nested member read in a localparam, a replication count and an indexed part-select width
module child import p::*; #(parameter cfg_t Cfg = '0) (input logic [15:0] x, output logic [15:0] w, output logic [15:0] v);
  localparam int unsigned A = Cfg.u.a;
  assign w = {Cfg.u.a{1'b1}};
  assign v = x[A-1:0];
endmodule
module top import p::*; #(parameter cfg_t Cfg = p::C) (input logic [15:0] x, output logic [15:0] w, output logic [15:0] v);
  child #(.Cfg(Cfg)) u_c (.x(x), .w(w), .v(v));
endmodule
