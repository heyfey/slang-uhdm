// § hpElemSelNameIsPathSoFar154
package ip; typedef struct packed { logic [3:0] adr; logic v; } req_t; endpackage
interface inner; ip::req_t q [4]; endinterface
interface outer; inner sub(); endinterface
module top(output logic [3:0] o);
  outer ob();
  assign o = ob.sub.q[3].adr;
endmodule
