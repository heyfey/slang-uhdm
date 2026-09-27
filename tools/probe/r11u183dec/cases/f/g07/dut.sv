package p;
typedef bit [7:0] be_t;
typedef struct { int n; be_t byte_en; be_t other; } op_t;
be_t pv;
function automatic be_t f(be_t a); return a; endfunction
endpackage
module top;
  p::be_t mv;
  p::op_t ov;
endmodule
