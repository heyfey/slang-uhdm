// § packedStructNdaFoldConstLoc155
package pk; typedef struct packed { logic [7:0] word; } my_struct; endpackage
module top(output logic [7:0] o);
  pk::my_struct s = '{word: 99};
  assign o = s.word;
endmodule
