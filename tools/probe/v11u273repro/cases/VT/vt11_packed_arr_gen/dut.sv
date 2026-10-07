// § typeParamStructLastNetParent273
module dut (input logic [9:0] i, output logic [9:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  for (genvar k = 0; k < 2; k++) begin : g
    T [0:0] pa;
    always_comb pa = i[k*5 +: 5];
    assign o[k*5 +: 5] = pa;
  end
endmodule
