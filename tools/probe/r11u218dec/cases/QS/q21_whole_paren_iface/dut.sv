// § pkgQualOperandSpanInParam218 — q21_whole_paren_iface: a parenthesized whole initializer inside an interface
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
interface ifc;
  localparam logic [11:0] A = (dm::DataAddr);
  logic [11:0] v;
  assign v = A;
endinterface
module top(output logic [11:0] o);
  ifc i();
  assign o = i.v;
endmodule
