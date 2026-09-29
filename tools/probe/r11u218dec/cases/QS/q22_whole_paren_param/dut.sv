// § pkgQualOperandSpanInParam218 — q22_whole_paren_param: a parenthesized whole initializer of an overridable parameter, overridden at one instance
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
endpackage
module m #(parameter logic [11:0] A = (dm::DataAddr)) (output logic [11:0] o);
  assign o = A;
endmodule
module top(output logic [11:0] o, output logic [11:0] p);
  m u(.o(o));
  m #(.A(12'h5)) w(.o(p));
endmodule
