// ROAD A cell set: WHICH $bits ARGUMENT KIND does Surelog's compileBits fold?
// One module, one holder (body localparam), six argument kinds.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t; // 97
  typedef logic [7:0] byte_t;                                               // 8
endpackage
module dut #(
    parameter type TP  = pk::req_t,          // TYPE PARAMETER (port list)
    parameter int  UNUSED = 0
) (
    output logic o
);
  typedef pk::req_t loc_t;                   // module-local typedef alias
  localparam type TL = pk::req_t;            // TYPE LOCALPARAM
  localparam int W1 = $bits(TP);             // arg = type parameter
  localparam int W2 = $bits(pk::req_t);      // arg = package-qualified typedef
  localparam int W3 = $bits(loc_t);          // arg = module-local typedef
  localparam int W4 = $bits(TL);             // arg = type localparam
  localparam int W5 = $bits(pk::byte_t);     // arg = package scalar typedef
  localparam int W6 = $bits(logic [9:0]);    // arg = built-in type keyword
  assign o = ^{W1[0], W2[0], W3[0], W4[0], W5[0], W6[0]};
endmodule
