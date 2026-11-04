// § ifaceLowConnFirstSignal293
// Body-first with several declarators.
interface ifc (o, p);
  wire [7:0] o, p;
  output [7:0] o, p;
  assign o = 8'd9;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
