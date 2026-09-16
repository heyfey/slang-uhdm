// v11u53 BREAK-10: the shadowing face inside an INTERFACE.
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } req_t;  // 8
  typedef logic [7:0] TP;                                          // 8
endpackage
interface ifc import pk::*; #(
    parameter type TP = pk::req_t
) ();
  localparam int W = $bits(TP);
  localparam int C = $bits(pk::req_t);
  logic [W-1:0] a;
  logic [C-1:0] b;
endinterface
module dut (output logic o);
  ifc u();
  assign o = ^{u.a[0], u.b[0]};
endmodule
