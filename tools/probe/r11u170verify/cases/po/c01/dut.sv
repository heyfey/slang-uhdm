// § ovPkgPatOpInstanceCopy163
package pkg;
  typedef struct packed { logic a; logic [2:0] b; } rsp_t;
  parameter rsp_t RSP_DEFAULT = '{a: 1'b1, b: 3'd5};
endpackage
module leaf #(parameter P = 0) (output logic [3:0] o); assign o = P; endmodule
module mid #(parameter Q = 0) (output logic [3:0] o); leaf #(.P(Q)) l(.o(o)); endmodule
module top (output logic [3:0] o); mid #(.Q(pkg::RSP_DEFAULT)) m(.o(o)); endmodule
