// § typeParamStructLastNetParent273
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam type T = union packed { logic [7:0] a; logic [7:0] b; };
  T u;
  assign u = i;
  assign o = u.b;
endmodule
