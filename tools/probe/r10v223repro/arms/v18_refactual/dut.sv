// v18 — ONE top, so both producers name the design the same and the judge
// can walk past it: does an interface's reference to a WILDCARD-IMPORTED
// package variable acquire a vpiActual the def view's new net?
package pv18;
  logic [3:0] lv18;
  int iv18;
endpackage

interface if_v18;
  import pv18::*;
  logic [3:0] own_v18;
  assign own_v18 = lv18;
endinterface

module top_v18;
  if_v18 u_if();
endmodule
