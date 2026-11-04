// § paramBaseSelTsInstName168 § memLeftFormalArgLoc169 § memLeftSliceUnlocated169
package p;
  typedef struct packed { int unsigned A; int unsigned B; } cfg_t;
  function automatic cfg_t mk(int unsigned x);
    cfg_t c;
    c.A = x;
    c.B = x + 1;
    return c;
  endfunction
endpackage
module sub #(parameter p::cfg_t C = p::mk(2)) (input [7:0] v, output [3:0] o);
wire [3:0] w = v[C.A+3:C.A];
assign o = w;
endmodule
module top(input [7:0] v, output [3:0] o); sub s(.v(v), .o(o)); endmodule
