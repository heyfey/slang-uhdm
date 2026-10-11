// § genCaCatMemberInst284
interface ifc(input logic a);
  localparam logic [63:0] P = 1;
  logic [31:0] o;
  assign o[31:8] = 0;
  if (1) begin : g
    assign o[7:0] = {P, a};
  end
endinterface
module dut(input logic a, output logic [31:0] o);
  ifc u(.a(a));
  assign o = u.o;
endmodule
