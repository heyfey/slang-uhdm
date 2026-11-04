// § packedStructNdaFoldConstLoc155
typedef struct packed { logic [7:0] word; } my_struct;
module top(output logic [7:0] o);
  my_struct s = '{word: 8};
  assign o = s.word;
endmodule
