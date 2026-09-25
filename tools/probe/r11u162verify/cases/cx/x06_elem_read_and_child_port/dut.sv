// § hpElemSelNameIsPathSoFar154 § ifaceSigConnNamedByChildPort155
package ip; typedef struct packed { logic [3:0] adr; } req_t; endpackage
interface myif (input logic clk);
  ip::req_t rq [2];
  logic sig;
  modport s (input clk, input rq, output sig);
endinterface
module child (input logic clk, output logic q); always_ff @(posedge clk) q <= ~q; endmodule
module mid (myif.s sub, output logic q, output logic [3:0] a);
  child c (.clk(sub.clk), .q(q));
  assign a = sub.rq[0].adr;
  assign sub.sig = q;
endmodule
module dut (input logic clk, output logic q, output logic [3:0] a); myif mif (.clk(clk)); mid m (.sub(mif), .q(q), .a(a)); endmodule
