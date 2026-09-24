// § pkgPatReadTsNoParent131
// case t02: a package pattern parameter imported by name and read unqualified in a continuous assignment
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } cfg_t;
  parameter cfg_t CFG = '{a: 4'd1, b: 4'd2};
endpackage
module top(output logic [3:0] y);
  import pk::CFG;
  assign y = CFG.b;
endmodule
