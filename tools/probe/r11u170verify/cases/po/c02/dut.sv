// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic a; logic [2:0] b; } rsp_t;
  typedef struct packed { rsp_t r; logic [3:0] c; } big_t;
  parameter big_t BIG_DEFAULT = '{r: '{a: 1'b0, b: 3'd2}, c: 4'hC};
endpackage
module leaf #(parameter P = 0) (output logic [7:0] o); assign o = P; endmodule
module top (output logic [7:0] o [3]);
  for (genvar g = 0; g < 3; g++) begin : G
    leaf #(.P(pkg::BIG_DEFAULT)) l(.o(o[g]));
  end
endmodule
