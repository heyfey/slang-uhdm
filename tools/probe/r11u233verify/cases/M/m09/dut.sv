// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — generate-for instances whose one override expression selects an untyped pattern on i==0 and a cast otherwise
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   localparam int N = Info.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
module top(output logic [7:0] o [2]);
   for (genvar i = 0; i < 2; i++) begin : g
      sub #(.Info(i == 0 ? '{x: 5} : info_t'(6))) u (.o(o[i]));
   end
endmodule
