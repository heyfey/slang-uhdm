// § genCaLhsEnumConstClone158
module sub(input logic [3:0][7:0] a, output logic [3:0][7:0] o);
  typedef enum logic [1:0] {A, B, C, D} e_t;
  if (1) begin : g
    assign o[C:A] = a[C:A];
  end
  assign o[D] = a[D];
endmodule
module dut(input logic [3:0][7:0] a, output logic [3:0][7:0] o);
  sub u(.a(a), .o(o));
endmodule
