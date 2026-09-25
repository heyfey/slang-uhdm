// § packedStructNdaFoldConstLoc155
module top(output logic [7:0] o);
   typedef struct packed { logic [3:0] a; logic [3:0] b; } my_struct;
   my_struct s = '{default: 3};
   assign o = s;
endmodule
