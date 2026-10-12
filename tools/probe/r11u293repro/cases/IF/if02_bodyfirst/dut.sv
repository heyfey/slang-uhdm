// § ifaceLowConnFirstSignal293
// Body nets above the port declarations.
interface ifc (o, p);
  wire [31:0] o;
  wire [31:0] p;
  output [31:0] o;
  output [31:0] p;
  assign o = 32'd3;
  assign p = o;
endinterface
module top (output logic [31:0] o);
  logic [31:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
