// § caReduceOpKindGate276
interface ifc #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, n2);
  logic [7:0] o;
  assign o = (P & n) ^ n2;
endinterface
module dut (input logic [7:0] n, n2, output logic [7:0] o);
  ifc u (.n(n), .n2(n2));
  assign o = u.o;
endmodule
