// § selLhsBareDecRhsShared171 § elabStructMemberOpFoldUnlocated174
package p;
  typedef struct packed {
    int unsigned A;
    int unsigned B;
  } cfg_t;
  function automatic cfg_t mk(int unsigned x, int unsigned y);
    cfg_t c;
    c.A = x;
    c.B = y;
    return c;
  endfunction
  localparam cfg_t D = mk(16, 2);
endpackage
module sub #(parameter p::cfg_t Cfg = p::D, localparam int X = Cfg.A / Cfg.B) (output wire [31:0] c);
  assign c[X-1:0] = 5;
  assign c[X] = 1;
  assign c[31:X+1] = 0;
endmodule
module dut (output wire [31:0] a, b);
  sub u1(a);
  sub u2(b);
endmodule
