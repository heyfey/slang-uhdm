// § packedStructNdaFoldConstLoc155
module sub(output logic [7:0] o);
  typedef struct packed { logic [7:0] word; } my_struct;
  my_struct s = '{17};
  assign o = s.word;
endmodule
module top(output logic [7:0] o1, o2); sub a(o1); sub b(o2); endmodule
