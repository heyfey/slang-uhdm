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
  function automatic ucfg_t setcfg();
    ucfg_t c;
    c.a = 7;
    c.flag1 = 1'b1;
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
module top(output logic [6:0] w, output logic f);
  assign w = {p::C.u.a{1'b1}};
  assign f = p::C.u.flag1;
endmodule
