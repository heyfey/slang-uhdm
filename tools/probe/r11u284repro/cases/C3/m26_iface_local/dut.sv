// § genCaCatMemberInst284
interface ifc(input logic a);
  localparam logic [63:0] P = 1;
  logic [31:0] o;
  if (1) begin : g
    logic [31:0] lv;
    assign lv = {P, a};
    assign o = lv;
  end
endinterface
module dut(input logic a, output logic [31:0] o);
  ifc u(.a(a));
  assign o = u.o;
endmodule
