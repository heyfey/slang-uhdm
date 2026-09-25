// § psBoundBareRefByBase145
interface ifc #(parameter int H = 7, parameter int L = 4);
  logic [31:0] a;
  logic [3:0] o;
  assign o = a[H:L];
endinterface
module dut(output logic [3:0] o);
  ifc i();
  assign o = i.o;
endmodule
