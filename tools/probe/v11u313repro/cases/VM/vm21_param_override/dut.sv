// § ifaceHcSelNamedByInst313
interface ifp #(parameter int W = 1) (input logic clk);
  logic [W-1:0] sig;
  modport mp (input sig, input clk);
endinterface
module top (input logic [1:0] ck, input logic s, output logic o);
  ifp #(.W(2)) u (.clk(ck[s]));
  assign o = u.sig[0];
endmodule
