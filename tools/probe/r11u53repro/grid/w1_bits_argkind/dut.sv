// r11u53 ROAD A cell set — WHICH $bits ARGUMENT KIND does the producer fold?
// One module, one holder (module-body localparam), eight argument kinds.
// Cells 1/2/3 are the LAW's side (type parameters / localparam type); cell 2
// is the V5 decisive cell (the type parameter is bound to a BUILT-IN keyword,
// so the RESOLVED type is fully specified and golden STILL keeps the call);
// cell 4 is the separate view-dependent W3 cell; 5-8 are the POSITIVE CONTROL
// (same construct, same holder, same view, golden and ours agree).
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  typedef logic [7:0] byte_t;                                               // 8
endpackage
module dut #(
    parameter type TP  = pk::req_t,          // 1 TYPE PARAMETER -> pkg struct
    parameter type TB  = logic [9:0],        // 2 TYPE PARAMETER -> BUILT-IN
    parameter type TS  = pk::byte_t,         // 2b TYPE PARAMETER -> pkg scalar
    parameter int  UNUSED = 0
) (
    output logic o
);
  typedef pk::req_t loc_t;                   // module-local typedef alias
  localparam type TL = pk::req_t;            // 3 LOCALPARAM TYPE
  localparam int W1 = $bits(TP);             // type parameter (pkg struct)
  localparam int W2 = $bits(TB);             // type parameter (built-in)  V5
  localparam int W2B = $bits(TS);            // type parameter (pkg scalar)
  localparam int W3 = $bits(TL);             // localparam type
  localparam int W4 = $bits(loc_t);          // module-local typedef      W3 cell
  localparam int W5 = $bits(pk::req_t);      // CONTROL package struct typedef
  localparam int W6 = $bits(pk::byte_t);     // CONTROL package scalar typedef
  localparam int W7 = $bits(logic [9:0]);    // CONTROL built-in keyword
  assign o = ^{W1[0], W2[0], W2B[0], W3[0], W4[0], W5[0], W6[0], W7[0]};
endmodule
