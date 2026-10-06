// § macroIfaceRangeSelBaseTok256 (a modport port select written in a macro inside a for-generate)
package fp;
  parameter int FW = 2;
  parameter int PW = 3;
endpackage
`define wr(P, L) assign P.d[L +: 2] = x[L +: 2];
interface bif; logic [7:0] d; modport mp(output d); endinterface
module m(bif.mp p, input logic [7:0] x);
  for (genvar i = 0; i < 4; i++) begin : gb
    `wr(p, i*2)
  end
endmodule
module top(input logic [7:0] x); bif b(); m u (.p(b), .x(x)); endmodule
