// § genChildParentAtBirth261
interface ifc (input logic [31:0] d);
  logic [15:0] o;
  assign o = d[31:16] ^ d[15:0];
endinterface
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o);
  if (B) begin : g_b
    ifc i (.d(d));
    assign o = i.o;
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
