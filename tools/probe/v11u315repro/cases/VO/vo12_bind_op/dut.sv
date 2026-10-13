// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module tgt (input logic [1:0] ck, output logic o);
  assign o = ck[0];
endmodule
module chk (input logic [1:0] ck);
  ifc u (.clk(ck[0] & ck[1]));
endmodule
module top (input logic [1:0] ck, output logic o);
  tgt t (.ck(ck), .o(o));
  bind tgt chk c (.ck(ck));
endmodule
