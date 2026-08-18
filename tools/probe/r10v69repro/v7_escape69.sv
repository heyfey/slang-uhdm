// r10v69 arm v7 - ESCAPED identifiers whose names CONTAIN brackets, and other
// texts that could desynchronise the name/element lockstep walk.
package pv7;
  parameter int XA = 2;
  parameter int XB = 3;
endpackage

typedef struct packed { logic [31:0] mm; } rec7_t;

module v7 import pv7::*; ();
  localparam int YA = 2;
  rec7_t arr [4];
  rec7_t \esc[2] [4];
  logic [7:0] o [64];
  logic       ob [64];

  for (genvar i = 0; i < 2; i++) begin : g7
    // an ESCAPED array name that itself contains brackets
    assign o[0] = \esc[2] [i].mm[XA+:XB];
    assign o[1] = \esc[2] [XA].mm[YA+:XB];
    // ordinary control
    assign o[2] = arr[i].mm[XA+:XB];
    // param index in the base, param bounds in the tail
    assign o[3] = arr[XA].mm[XA+:XB];
  end
  assign o[16] = \esc[2] [0].mm[XA+:XB];
  assign o[17] = arr[0].mm[XA+:XB];
endmodule
