// § pkgAliasOfKwBind250
package p;
  typedef byte b_t;
  typedef b_t c_t;
  typedef shortint s_t;
  typedef s_t t_t;
endpackage
interface ifc;
  import p::*;
  c_t v;
  t_t u;
endinterface
program prg;
  import p::*;
  c_t pv;
endprogram
module top;
  import p::*;
  ifc i0();
  prg g0();
  if (1) begin : g
    c_t gv;
  end
  p::t_t q;
endmodule
