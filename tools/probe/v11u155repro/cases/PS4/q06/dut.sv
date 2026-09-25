// § packedStructNdaFoldConstLoc155
module top(output logic [7:0] o);
   typedef struct packed { logic [7:0] b; } in_t;
   typedef struct packed { in_t inner; } my_struct;
   my_struct s = '{inner: '{b: 3}};
   assign o = s.inner.b;
endmodule
