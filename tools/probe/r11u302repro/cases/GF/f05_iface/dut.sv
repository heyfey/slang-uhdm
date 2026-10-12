// § elabImpSelFlatKeepsParent302
// f05: the importer is an interface instance
package p7;
  typedef struct packed { logic [31:0] a; logic [31:0] b; logic [31:0] c; } w7_t;
  localparam w7_t WSEL = '{a: 32'd4, b: 32'd5, c: 32'd6};
  localparam w7_t WNON = '{a: 32'd1, b: 32'd2, c: 32'd3};
  typedef logic [WSEL.a-1:0] w1_t;
endpackage
interface ifc import p7::*;;
  w1_t d;
endinterface
module dut(output logic o);
  ifc u();
  assign o = u.d[0];
endmodule
