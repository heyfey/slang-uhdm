// § varDeclInitMovesSharedTsEnd297
package pk;
  typedef enum logic [1:0] { A, B, C } e_t;
endpackage
module dut (input logic [7:0] pa, output logic o);
  pk::e_t s = pk::B;
  assign o = (s == pk::B) ^ pa[0];
endmodule
