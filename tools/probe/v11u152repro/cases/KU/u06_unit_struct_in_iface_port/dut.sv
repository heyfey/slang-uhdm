// § pkgElemMemberPatNoLoc152
package fp;
  typedef struct packed { logic a; logic b; } cf_t;
endpackage
typedef struct packed {
  fp::cf_t [3:0] at;
} tf_t;
interface ifc;
  tf_t v;
endinterface
module top(output logic o);
  ifc i();
  assign o = ^i.v;
endmodule
