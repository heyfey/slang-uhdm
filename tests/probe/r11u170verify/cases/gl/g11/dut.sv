// § genCaLhsEnumConstClone158
typedef enum int { E_LO = 1, E_HI = 3 } e_t;
module sub (input logic [3:0] a, output logic [7:0] o);
  for (genvar i = 0; i < 1; i++) begin : GI
    assign o[E_HI:E_LO] = a[2:0];
  end
endmodule
module top (input logic [3:0] a, output logic [7:0] o, output logic [7:0] o2);
  sub u1(.a(a), .o(o));
  sub u2(.a(~a), .o(o2));
endmodule
