// § pkgQualOperandSpanInParam218 — q25_pat_member_cast: control: a cast of a sum in a pattern member (probe x6)
package dm;
  localparam logic [3:0] DataCount = 4'h2;
  localparam logic [11:0] DataAddr = 12'h380;
  localparam int N = 3;
  typedef enum logic [7:0] { Data0 = 8'h04, Data1 = 8'h05 } dm_csr_e;
  typedef struct packed { logic [11:0] a; logic [7:0] b; } s_t;
endpackage
module m(output logic [19:0] o);
  localparam dm::s_t A = '{a: 12'(dm::N + 1), b: 8'h0};
  assign o = A;
endmodule
module top(output logic [19:0] o);
  m u(.o(o));
endmodule
