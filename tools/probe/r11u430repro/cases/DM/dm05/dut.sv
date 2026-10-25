// § structMemberDefaultParamRef430
package p;
  parameter int K = 9;
endpackage
module top ();
struct {
	int a = p::K;
	int b;
} v;
endmodule
