// § tsHierPathElemNoName134
module top #(parameter type T = logic)(output logic [7:0] o);
   typedef struct packed { int a; int b; } c_t;
   localparam c_t C = '{a: 8, b: 2};
   logic [C.a-1:0] x;
   logic [C.b:0] y;
   assign x = '1;
   assign y = '0;
   assign o = x;
endmodule
