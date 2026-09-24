// § tsHierPathElemNoName134
module top(output logic [7:0] o);
   typedef struct packed {
      int x;
      int y;
   } info_t;
   parameter info_t Info = '{x: 8, y: 2};
   localparam int N = Info.x;
   logic [N-1:0] data;
   assign data = '1;
   assign o = data;
endmodule
