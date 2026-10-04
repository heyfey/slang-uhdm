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
// two instances, one overriding with a pattern, one with the package localparam; the nested member in a dimension
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [Cfg.u.a-1:0] w);
  assign w = '1;
endmodule
module top import p::*; (output logic [6:0] w1, output logic [2:0] w2);
  child #(.Cfg(p::C)) u1 (.w(w1));
  child #(.Cfg('{u: '{a: 3, flag1: 1'b0, flag2: 1'b1}, d: 1})) u2 (.w(w2));
endmodule
