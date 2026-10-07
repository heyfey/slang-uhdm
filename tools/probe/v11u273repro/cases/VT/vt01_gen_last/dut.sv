// § typeParamStructLastNetParent273
module dut (input logic [4:0] i, output logic [4:0] o);
  localparam type T = struct packed { logic [3:0] a; logic b; };
  T s;
  always_comb s = i;
  if (1) begin : g
    T t;
    always_comb t = s;
    assign o = t;
  end
endmodule
