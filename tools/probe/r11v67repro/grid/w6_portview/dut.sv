// w6_portview -- the SECOND defView call site: the port-view BARE net minted
// when an interface-port net is not reachable through the connected modport
// (ModuleEmit.cpp:36467).  Plus a modport-reached typedef net.
package pk;
  typedef logic [1:0] cv_t;
  typedef reg   [1:0] cr_t;
endpackage
typedef logic [1:0] uv_t;
interface bus_if;
  import pk::*;
  typedef logic [1:0] lv_t;
  typedef reg   [1:0] lr_t;
  wire  cv_t  v01;
  wire  lv_t  v02;
  wire  lr_t  v03;
  lv_t        v04;
  cv_t        v05;
  wire  uv_t  v06;
  logic       clk;
  modport mp (input v02, output v04);
endinterface
module sink (bus_if.mp b, bus_if c);
  logic z;
  assign z = b.v02[0];
endmodule
module w6;
  bus_if bi ();
  sink u_sink (.b(bi), .c(bi));
endmodule
