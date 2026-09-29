// § strLitContOwnerEnd224 § initHierAtRefToken225 § initHierFillKept225 (a continued literal as the struct-member substituted signal's writer beside a fill)
module top(output int o, output logic [63:0] s);
   typedef struct packed { int x; } part_info_t;
   parameter part_info_t Info = part_info_t'(16);
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign s = "ab \
cd";
   assign o = int'(data);
endmodule
