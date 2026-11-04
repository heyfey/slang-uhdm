// § initHierAtRefToken225 § initHierCaLhsBareName225 § initHierFillKept225 § fillSymbolicRootOnly225v ('1 in an always_comb and an assign in one module, two signals)
module top(output int o);
   typedef struct packed { int x; int y; } part_info_t;
   parameter part_info_t Info = part_info_t'(64'h0000_0010_0000_0002);
   localparam int N = Info.x;
   logic [N-1:0] a, b;
   always_comb a = '1;
   assign b = '1;
   assign o = int'(a) + int'(b);
endmodule
