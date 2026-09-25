// § ovPatOpCopyAtLocalRef163v
package pkg;
  typedef struct packed { logic a; logic [2:0] b; } rsp_t;
endpackage
module leaf #(parameter P = 0) (output logic [3:0] o); assign o = P; endmodule
module top (output logic [3:0] o);
  localparam pkg::rsp_t L = '{a: 1'b0, b: 3'd6};
  leaf #(.P( (L) )) l(.o(o));
endmodule
