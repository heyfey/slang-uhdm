// § varDeclInitMovesSharedTsEnd297
typedef enum logic [1:0] { A, B, C } e_t;
interface ifc;
  var e_t s = C;
endinterface
module dut(output logic [1:0] o, p);
  ifc i1();
  ifc i2();
  assign o = i1.s;
  assign p = i2.s;
endmodule
