// § genLoopDirectBoundPaCopy280
// an interface body's for-generate
interface ifc (input logic [31:0] sig);
  localparam logic [3:0] R4 = {2{2'b01}};
  for (genvar i = 0; i < 2; i++) begin : g
    logic [1:0] y;
    assign y = sig[R4 +: 2];
  end
endinterface
module top (input logic [31:0] sig, output logic [63:0] z);
  ifc u (.sig(sig));
  assign z = 64'b0;
endmodule
