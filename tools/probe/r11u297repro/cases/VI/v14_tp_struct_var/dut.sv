// § varDeclInitMovesSharedTsEnd297
module dut #(parameter type t_t = struct packed { logic [3:0] a; logic [3:0] b; }) (input logic [7:0] pa, output logic o);
  var t_t x = 8'h5a;
  assign o = x[0] ^ pa[0];
endmodule
