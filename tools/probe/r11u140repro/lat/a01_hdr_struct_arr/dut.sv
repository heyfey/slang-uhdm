// § impLhsCloneArrayTsOwnCopy140
package pk;
  typedef struct packed { logic [7:0] tag; logic acc; } entry_t;
  parameter int N = 2;
  parameter entry_t TBL[N] = '{'{tag: 8'hA1, acc: 1'b1}, '{tag: 8'hB2, acc: 1'b0}};
endpackage
module dut import pk::*; #(parameter int W = 1) (input logic sel, output logic [7:0] o);
  assign o = TBL[sel].tag;
endmodule
