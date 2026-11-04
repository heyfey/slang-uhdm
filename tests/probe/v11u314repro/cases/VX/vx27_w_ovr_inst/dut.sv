// § pkgQualIpsWidthSpanQualifier314
package p; localparam int N = 2; endpackage
typedef struct packed { logic [7:0] v; } a_t;
module c #(parameter int K = 1) (output logic [1:0] o); a_t a; always_comb o = a.v[K +: p::N]; endmodule
module top; logic [1:0] o; c #(.K(3)) u(.o(o)); endmodule
