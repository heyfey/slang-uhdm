// § pvHdrPortAtPortDecl305
interface ifc (o);
  output [7:0] o;
  wire [7:0] o = 8'd3;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o);
  ifc u_if (.o(o));
  if (1) begin : g
    sub u_s (.m(u_if.mp));
  end
endmodule
