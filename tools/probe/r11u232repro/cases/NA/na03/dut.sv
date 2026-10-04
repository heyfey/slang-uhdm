// § structCopyNestedAnnotDeep232
package p;
  typedef struct packed {
    int unsigned a;
    bit flag1;
  } ucfg_t;
  typedef struct packed {
    ucfg_t u;
    int unsigned d;
  } cfg_t;
  function automatic cfg_t build(input int unsigned x);
    cfg_t r;
    r.u = '0;
    r.d = x * 2;
    return r;
  endfunction
  localparam cfg_t C = build(3);
endpackage
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [Cfg.d-1:0] w);
  assign w = '1;
endmodule
module top import p::*; #(parameter cfg_t Cfg = p::C) (output logic [5:0] w);
  child #(.Cfg(Cfg)) u_c (.w(w));
endmodule
