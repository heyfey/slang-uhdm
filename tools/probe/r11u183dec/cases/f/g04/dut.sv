package p;
localparam W = 8;
typedef bit [W-1:0] be_t;
typedef struct { int n; be_t byte_en; } op_t;
endpackage
module top; endmodule
