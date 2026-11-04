// § ndaRangeQueryFold216 — $high in an interface net initializer
interface ifc (input logic [5:2] i);
  wire [3:0] w = $high(i);
endinterface
module dut (input logic [5:2] i, output logic [3:0] o);
  ifc u(.i(i));
  assign o = u.w;
endmodule
