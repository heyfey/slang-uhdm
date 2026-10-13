// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module child (ifc.mp p, output logic o);
  assign o = p.sig[0] ^ p.clk;
endmodule
module top (input logic [1:0] ck, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 1) begin : h
      ifc u (.clk(ck[i]));
      child c0 (.p(u), .o(o[i]));
    end else begin : e
      assign o[i] = 1'b0;
    end
  end
endmodule
