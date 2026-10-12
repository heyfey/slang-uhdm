// § ifCaConstDelayPerCell301
interface ifc (input logic [7:0] a);
  logic [7:0] p;
  assign #2 p = a;
endinterface
module dut (input logic [7:0] a, output logic [7:0] o);
  ifc u0 (.a(a));
  ifc u1 (.a(a));
  assign o = u0.p ^ u1.p;
endmodule
