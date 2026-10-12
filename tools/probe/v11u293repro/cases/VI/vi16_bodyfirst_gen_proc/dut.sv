// § ifaceLowConnFirstSignal293
// Body-first nets read by a generate block and a process.
interface ifc (o, p);
  wire [7:0] o;
  wire [7:0] p;
  output [7:0] o;
  output [7:0] p;
  logic [7:0] r;
  assign o = 8'd3;
  always_comb r = o;
  if (1) begin : g
    assign p = r;
  end
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
