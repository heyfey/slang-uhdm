// § structMemberDefaultParamRef430
module top ();
parameter c = 3;
typedef struct {
	int a = c;
	int b;
} s_t;
s_t v;
endmodule
