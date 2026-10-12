// § pvHdrPortDeclNetFirst305
interface ifc (o);
  output [7:0] o;
  wire [7:0] o = 8'd12;
  modport mp (output o);
endinterface
module sub (ifc.mp m);
endmodule
module dut (output logic [7:0] o0, output logic [7:0] o1);
  ifc u_if [1:0] (.o({o1, o0}));
  sub u_s0 (.m(u_if[0].mp));
  sub u_s1 (.m(u_if[1].mp));
endmodule
