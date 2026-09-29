// § pkgQualOperandSpanInParam218 — q14_int_mul: an int localparam product
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
module m(output logic [11:0] o);
  localparam int A = dm::N * 2;
  assign o = A;
endmodule
module top(output logic [11:0] o);
  m u(.o(o));
endmodule
