// § genConnTrailSelChain205: an interface-array element member bit select in a for-generate instance
interface bif;
  logic [3:0] d;
endinterface
module sub(input logic i, output logic o);
  assign o = i;
endmodule
module top(input logic [3:0] x, input logic [3:0] y, output logic [1:0] o);
  bif b [2] ();
  assign b[0].d = x;
  assign b[1].d = y;
  for (genvar k = 0; k < 2; k++) begin : g
    sub u(.i(b[k].d[3]), .o(o[k]));
  end
endmodule
