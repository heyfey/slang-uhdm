// § memberInitReducedRootFolds228 § memberRootFoldShapes228v § memberRootOwnInstance228v — a package struct constant read by member in a module (N = pk::INFO.x), untyped pattern
package pk;
   typedef struct packed { int x; } info_t;
   localparam info_t INFO = '{x: 16};
endpackage
module top(output logic [7:0] o);
   localparam int N = pk::INFO.x;
   logic [N-1:0] q;
   assign q = '1;
   assign o = 8'(q);
endmodule
