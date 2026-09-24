// § tsHierPathElemNoName134
// case h02: a range bound reading a nested member of a package struct parameter
package p;
  typedef struct packed { logic [3:0] w; } in_t;
  typedef struct packed { in_t i; logic [3:0] d; } cfg_t;
  parameter cfg_t CFG = '{i: '{w: 4'd6}, d: 4'd1};
endpackage
module top(output logic [7:0] o);
  logic [p::CFG.i.w-1:0] x;
  assign x = '1;
  assign o = x;
endmodule
