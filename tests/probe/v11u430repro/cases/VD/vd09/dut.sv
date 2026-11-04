// § structMemberDefaultParamRef430
module top ();
parameter c = 4'h5;
typedef struct { bit [3:0] lo = c; bit [3:0] hi; } s_t;
s_t a, b;
endmodule
