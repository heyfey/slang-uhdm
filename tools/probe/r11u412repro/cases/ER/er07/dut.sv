// § enumXzReplInitZero412
typedef enum integer {ta=0, tb={32{1'bx}}, tc=1} t_e;
module top();
	enum integer {a=0, b={32{1'bx}}, c=1} val;
	enum logic [3:0] {d=0, e={4{1'bz}}, f=2} v2;
	enum integer {g=0, h={2{16'hx}}} v3;
	t_e v4;
endmodule
