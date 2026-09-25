// § packedStructNdaFoldConstLoc155
`define V 8'd77
module top(output logic [7:0] o);
  typedef struct packed { logic [7:0] word; } my_struct;
  my_struct s = '{word: `V};
  assign o = s.word;
endmodule
