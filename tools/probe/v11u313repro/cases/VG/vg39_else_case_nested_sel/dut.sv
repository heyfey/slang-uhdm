// § genIfaceHcInnerRefUnbound313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top #(parameter int K = 0) (input logic [3:0] ck, input logic [1:0] s, output logic o);
  if (K == 1) begin : g
    assign o = 1'b0;
  end else begin : h
    case (K)
      0: begin : c
        ifc u (.clk(ck[s + 1]));
        child c0 (.p(u), .o(o));
      end
    endcase
  end
endmodule
