// § ifaceHcVarSelWholeByInst319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic a, output logic o);
  localparam int K = 1;
  case (K)
    1: begin : g
      ifc u (.clk(m[s][t]));
    end
  endcase
  assign o = a;
endmodule
