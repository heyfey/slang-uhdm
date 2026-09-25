// § packedStructNdaFoldConstLoc155
module top(output logic [7:0] o);
   typedef struct packed { logic [7:0] word; } my_struct;
   my_struct s = '{word: 8'd125};
   assign o = s.word;
endmodule
