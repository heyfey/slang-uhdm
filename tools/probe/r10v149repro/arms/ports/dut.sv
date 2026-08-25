// v149 arm 4 -- THE STRUCT AS A PORT: a struct carrying a queue member passed
// as an input port, as a ref port to a task, and through an interface port.
package Chi_pkg;
  typedef struct {
    string portArgs[$];
    int    portTag;
  } port_rec_t;
endpackage

interface Chi_ifc;
  import Chi_pkg::*;
  port_rec_t carried;
  modport srcmp (output carried);
  modport snkmp (input carried);
endinterface

module Chi_leaf (input Chi_pkg::port_rec_t inRec, output int outTag);
  assign outTag = inRec.portTag;
endmodule

module Chi_ifcuser (Chi_ifc.snkmp p);
  int seen;
  assign seen = p.carried.portTag;
endmodule

module ports_top;
  import Chi_pkg::*;
  port_rec_t driver;
  int tapped;
  Chi_leaf i_leaf (.inRec(driver), .outTag(tapped));
  Chi_ifc  i_bus ();
  Chi_ifcuser i_user (.p(i_bus.snkmp));
  initial driver.portTag = 11;
endmodule
