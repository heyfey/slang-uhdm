// § varDeclInitMovesSharedTsEnd297
interface ifc;
  typedef enum logic [1:0] { A, B, C } e_t;
  var e_t s = B;
endinterface
module dut (output logic o);
  ifc u ();
  assign o = u.s[0];
endmodule
