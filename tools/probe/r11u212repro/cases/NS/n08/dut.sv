// § signCastSysCallLhsTs212 — the signing cast onto an interface variable, in the interface body
interface bi (input logic [9:0] i);
  logic signed [6:0] v;
  assign v = signed'(i[6:0]);
endinterface
module dut (input logic [9:0] i, output logic [6:0] o);
  bi b (.i(i));
  assign o = b.v;
endmodule
