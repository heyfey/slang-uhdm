// § hpElemSelNameIsPathSoFar154 § ifaceSigConnNamedByChildPort155
package ip; typedef struct packed { logic [3:0] adr; } req_t; endpackage
interface myif (input logic clk);
  ip::req_t rq [2];
  logic sig;
  modport s (input clk, input rq, output sig);
endinterface
module child (input logic clk, input logic [3:0] a, output logic q); always_ff @(posedge clk) q <= ^a; endmodule
module mid (myif.s sub, output logic q);
  child c (.clk(sub.clk), .a(sub.rq[1].adr), .q(q));
  assign sub.sig = q;
endmodule
module dut (input logic clk, output logic q); myif mif (.clk(clk)); mid m (.sub(mif), .q(q)); endmodule
