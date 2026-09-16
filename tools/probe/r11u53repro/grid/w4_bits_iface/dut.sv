// r11u53 ROAD A interface twin — the same type-parameter and localparam-type
// arguments inside an INTERFACE body (Surelog compiles an interface through
// the same `DesignComponent` getDataType/ports/signals lookup), with the
// package-typedef control beside them.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
endpackage
interface ifc #(
    parameter type TP = pk::req_t,
    parameter type TB = logic [9:0]
) ();
  localparam type TL = pk::req_t;
  localparam int IW1 = $bits(TP);            // type parameter -> pkg struct
  localparam int IW2 = $bits(TB);            // type parameter -> built-in  V5
  localparam int IW3 = $bits(TL);            // localparam type
  localparam int IW4 = $bits(pk::req_t);     // CONTROL
  logic [IW1-1:0] a;
  logic [IW2-1:0] b;
  logic [IW3-1:0] c;
  logic [IW4-1:0] d;
endinterface
module dut (output logic o);
  ifc u();
  assign o = ^{u.a[0], u.b[0], u.c[0], u.d[0]};
endmodule
