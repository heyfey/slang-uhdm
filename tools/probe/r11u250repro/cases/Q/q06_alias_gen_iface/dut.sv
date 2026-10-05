// § pkgAliasOfKwBind250
package p;
  typedef realtime r_t;
  typedef r_t s_t;
  typedef integer g_t;
  typedef g_t h_t;
endpackage
interface ifc;
  import p::*;
  h_t v;
endinterface
module top;
  import p::*;
  ifc u();
  if (1) begin : g
    s_t t;
    h_t w;
  end
  p::h_t z;
endmodule
