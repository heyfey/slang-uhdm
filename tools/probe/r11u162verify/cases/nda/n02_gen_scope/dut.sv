// § packedStructNdaFoldConstLoc155
module top(output logic [7:0] o);
  typedef struct packed { logic [7:0] word; } my_struct;
  if (1) begin : g
    my_struct s = '{word: 42};
    assign o = s.word;
  end
endmodule
