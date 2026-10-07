// § caReduceOpKindGate276
interface ifc #(parameter logic [7:0] P = 8'h3C) (input logic [7:0] n, m);
  logic [7:0] o;
  assign o = (P & n) ^ m;
endinterface
module dut (input logic [7:0] n, m, output logic [7:0] o);
  ifc u(.n(n), .m(m));
  assign o = u.o;
endmodule
