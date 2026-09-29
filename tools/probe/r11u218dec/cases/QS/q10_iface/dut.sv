// § pkgQualOperandSpanInParam218 — q10_iface: an interface localparam
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
interface bus_if;
  localparam logic [11:0] A = dm::DataAddr + 2;
  logic [11:0] d;
  assign d = A;
endinterface
module m(output logic [11:0] o);
  bus_if b();
  assign o = b.d;
endmodule
module top(output logic [11:0] o);
  m u(.o(o));
endmodule
