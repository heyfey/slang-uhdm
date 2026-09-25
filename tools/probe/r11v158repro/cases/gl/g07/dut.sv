// § genCaLhsEnumConstClone158
interface ifc(input logic [7:0] a);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  logic [3:0][7:0] o;
  for (genvar i = 0; i < 1; i++) begin : g
    assign o[B] = a;
  end
endinterface
module dut(input logic [7:0] a, output logic [7:0] q);
  ifc u(.a(a));
  assign q = u.o[1];
endmodule
