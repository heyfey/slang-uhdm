// § genIfaceConnGenScopeName313
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module tgt (input logic [1:0] ck, output logic o);
  if (1) begin : g
    ifc u (.clk(ck[0] ^ ck[1]));
    assign o = u.sig[0];
  end
endmodule
module chk (input logic [1:0] ck);
  logic w;
  assign w = ck[0];
endmodule
module top (input logic [1:0] ck, output logic o);
  tgt t (.ck(ck), .o(o));
endmodule
bind tgt chk c (.ck(ck));
