// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — the member signal in a generate block, two instances (untyped, cast)
typedef struct packed { int x; } info_t;
module sub #(parameter info_t Info = '{x: 4}) (output logic [7:0] o);
   if (1) begin : g
      localparam int N = Info.x;
      logic [N-1:0] q;
      assign q = '1;
      assign o = 8'(q);
   end
endmodule
module top(output logic [7:0] o1, o2);
   sub #(.Info('{x: 5})) u1 (.o(o1));
   sub #(.Info(info_t'(6))) u2 (.o(o2));
endmodule
