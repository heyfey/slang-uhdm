// § packedStructNdaFoldConstLoc155
module top(output logic [7:0] o);
   localparam logic [7:0] P = 8'd9;
   typedef struct packed { logic [7:0] word; } my_struct;
   my_struct s = '{word: P};
   assign o = s.word;
endmodule
