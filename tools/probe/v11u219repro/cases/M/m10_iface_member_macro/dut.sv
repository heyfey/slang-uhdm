// § ppDotNameAfterArgToken219 — an interface member read and written through macro actuals, nested once
interface bus_if;
  logic valid;
  logic [7:0] data;
endinterface
`define VLD(IF) IF.valid
`define DAT(IF) IF.data
`define CPY(D, S) \
  assign `DAT(D) = `DAT(S); \
  assign `VLD(D) = `VLD(S);
module top(output logic v, output logic [7:0] d);
  bus_if a();
  bus_if b();
  assign a.valid = 1'b1;
  assign a.data = 8'h5A;
  `CPY(b, a)
  assign v = `VLD(b);
  assign d = `DAT(b);
endmodule
