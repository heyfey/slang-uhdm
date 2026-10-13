// § ifaceHcSelNamedByInst313
interface ifc (input logic clk);
  logic [7:0] sig;
  modport mp (input sig, input clk);
endinterface
module tgt (input logic [1:0] ck, output logic o);
  assign o = ck[0];
endmodule
module top (input logic [1:0] ck, output logic o);
  tgt t (.ck(ck), .o(o));
endmodule
bind tgt ifc bi (.clk(ck[1]));
