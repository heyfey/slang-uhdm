// § ifaceFirstSignalBindsRefs293
// A modport-imported function reads the port-first net.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  assign o = 8'd6;
  function automatic logic [7:0] get();
    return o;
  endfunction
  assign p = get();
  modport mp (import get);
endinterface
module sub (ifc.mp m, output logic [7:0] z);
  assign z = m.get();
endmodule
module top (output logic [7:0] o, output logic [7:0] z);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
  sub u_s (.m(u_if), .z(z));
endmodule
