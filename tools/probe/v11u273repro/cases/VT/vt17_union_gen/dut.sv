// § typeParamStructLastNetParent273
module dut (input logic [7:0] i, output logic [7:0] o);
  localparam type T = union packed { logic [7:0] a; logic [7:0] b; };
  if (1) begin : g
    T u;
    always_comb u = i;
    assign o = u.a;
  end
endmodule
