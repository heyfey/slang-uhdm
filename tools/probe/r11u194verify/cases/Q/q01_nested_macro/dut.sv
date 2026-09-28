// § macroPathTokSpans183 § macroPathTokOneBuffer186: dotted interface paths built by nested macros (the path in the inner macro's body, the interface name an outer argument) in continuous assignments
`define RD(IF, F) IF.F
`define DRIVE(IF, V) assign `RD(IF, data) = V; \
  assign `RD(IF, bits) = V[3:0];
interface bif;
  logic [7:0] data;
  logic [3:0] bits;
endinterface
module m (bif port_if, input logic [7:0] src);
  `DRIVE(port_if, src)
endmodule
module top;
  bif b ();
  m u (.port_if(b), .src(8'h5A));
endmodule
