// § ifaceFirstSignalBindsRefs293
// CONTROL: the module twin (no mint).
module mm (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd1;
  assign p = o;
endmodule
module top (output logic [7:0] o);
  logic [7:0] q;
  mm u_m (.o(o), .p(q));
endmodule
