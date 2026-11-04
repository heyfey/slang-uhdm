// § ovPatOpCopyAtLocalRef163v
package pkg;
  typedef struct packed { logic a; logic [2:0] b; } rsp_t;
endpackage
module leaf #(parameter P = 0) (output logic [3:0] o); assign o = P; endmodule
module mid #(parameter pkg::rsp_t H = '{a: 1'b1, b: 3'd1}) (output logic [3:0] o);
  leaf #(.P(H)) l(.o(o));
endmodule
module top (output logic [3:0] o); mid m(.o(o)); endmodule
