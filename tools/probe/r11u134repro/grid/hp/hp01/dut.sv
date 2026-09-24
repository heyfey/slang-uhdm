// § tsHierPathElemNoName134
module top(output logic [3:0] o);
   typedef struct packed { int x; } part_info_t;
   localparam part_info_t Info = '{x: 4};
   logic [Info.x-1:0] data;
   assign data = '1;
   assign o = data;
endmodule
