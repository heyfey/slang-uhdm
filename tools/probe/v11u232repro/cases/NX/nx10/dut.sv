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
// the package localparam U read directly (ucfg_t) beside C
module top import p::*; (output logic [U.a-1:0] w, output logic [C.u.a-1:0] v);
  assign w = '1;
  assign v = '0;
endmodule
