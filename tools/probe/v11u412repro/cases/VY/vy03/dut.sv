// § modNettypeTypedef412
interface ifc;
  nettype real irn;
endinterface
package pk;
  nettype real prn;
endpackage
module top;
  ifc i();
  typedef struct { real a; } s_t;
  nettype s_t sn;
endmodule
