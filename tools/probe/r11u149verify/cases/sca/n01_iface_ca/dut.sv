// § sysArgUnaryWholeSpan140
interface bus_if;
  logic [7:0] a;
  logic [7:0] w;
  assign w = $unsigned(~a);
endinterface
module dut(input logic [7:0] x, output logic [7:0] y);
  bus_if b();
  assign b.a = x;
  assign y = b.w;
endmodule
