// ROAD D: the SIZE a wrapper's reduced value carries, as a PACKAGE localparam
// assignment-pattern element.  Four wrapper kinds against the bare literal.
package pk;
  typedef struct packed {
    int unsigned A; int unsigned B; int unsigned C; int unsigned D;
  } four_t;
  localparam four_t Q = '{
      A: unsigned'(64),      // signedness cast
      B: $unsigned(64),      // system call form
      C: 32'(64),            // width cast
      D: 64 };               // bare literal (control)
endpackage
module dut (output logic [31:0] o);
  assign o = pk::Q.A | pk::Q.B | pk::Q.C | pk::Q.D;
endmodule
