// § emptyRedefineObjLine130
`define X
module top(input logic [3:0] a,
           output logic [3:0] o);
`define X
  logic [3:0] q;
  always_comb begin
    q = a;
  end
  assign o = q;
endmodule
module m2(input logic a, output logic y);
  assign y = a;
endmodule
