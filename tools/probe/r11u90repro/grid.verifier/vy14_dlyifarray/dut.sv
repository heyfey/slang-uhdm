// v11u90 vy14 -- an ARRAY of interface instances, each with the delay-ref
// cell: the clone must give each element its own bound reference.
interface ifc ();
  parameter int D = 4;
  logic [31:0] c;
  assign #D c = 32'd10;
endinterface
module dut (output logic [31:0] o);
  ifc u_if [0:1] ();
  assign o = u_if[0].c ^ u_if[1].c;
endmodule
