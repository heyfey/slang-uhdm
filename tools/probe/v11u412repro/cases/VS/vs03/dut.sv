// § unpStructArrElemVar412
package pk;
  typedef struct { logic [3:0] a; } ms_t;
  ms_t parr[3];
endpackage
module top(output logic [3:0] o);
  pk::ms_t marr[2][2];
  assign marr[0][1].a = 4'd5;
  assign o = marr[0][1].a;
endmodule
