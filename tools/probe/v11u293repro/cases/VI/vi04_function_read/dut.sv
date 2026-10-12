// § ifaceFirstSignalBindsRefs293
// An interface function reads the port-first net.
interface ifc (o, p);
  output [7:0] o;
  output [7:0] p;
  wire [7:0] o;
  wire [7:0] p;
  function automatic logic [7:0] rd();
    rd = o + 8'd1;
  endfunction
  assign o = 8'd5;
  assign p = rd();
endinterface
module top (output logic [7:0] o);
  logic [7:0] q;
  ifc u_if (.o(o), .p(q));
endmodule
