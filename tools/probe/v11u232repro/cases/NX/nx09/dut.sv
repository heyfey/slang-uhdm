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
// the nested struct parameter passed on its own (a ucfg_t parameter), two levels, in a generate block
module leaf import p::*; #(parameter ucfg_t U = '0) (output logic [U.a-1:0] w);
  assign w = '1;
endmodule
module child import p::*; #(parameter cfg_t Cfg = '0) (output logic [Cfg.u.a-1:0] w);
  if (Cfg.u.flag1) begin : g
    leaf #(.U(Cfg.u)) l (.w(w));
  end
endmodule
module top import p::*; (output logic [6:0] w);
  child #(.Cfg(p::C)) u_c (.w(w));
endmodule
