// ROAD C control: an INTERFACE-BODY typedef (CompileModule.cpp:1130 is the
// interface-body twin of :653).
interface ifc #(parameter int unsigned NDATA = 2, parameter int unsigned DEPTH = 4) ();
  typedef logic [NDATA-1:0] pk1_t [DEPTH];
  typedef logic [NDATA-1:0] pl1_t;
  pk1_t a;
  pl1_t b;
endinterface
module dut (output logic [1:0] o);
  ifc u();
  assign o = u.b | u.a[0];
endmodule
