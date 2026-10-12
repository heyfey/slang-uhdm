// § ifaceLowConnFirstSignal293
// One port body-first, one port-declaration-first.
interface ifc (o, p);
  wire [7:0] o;
  output [7:0] o;
  output [7:0] p;
  wire [7:0] p;
  assign o = 8'd4;
  assign p = o;
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
