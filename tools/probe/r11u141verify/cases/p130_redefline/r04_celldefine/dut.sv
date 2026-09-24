// § emptyRedefineObjLine130
// case r04: an empty redefinition inside a celldefine region, then an ifdef on it
`celldefine
`define Q
`define Q
`endcelldefine
module top(input logic a, output logic y);
`ifdef Q
  assign y = a;
`else
  assign y = ~a;
`endif
endmodule
