// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a parameter-width enum override, a cast continuous assignment and a T-typed localparam in the child
module sub #(parameter type T = logic, parameter int W = 2) (input T si, output T so, output logic [W-1:0] o);
  localparam T D = T'(0);
  assign so = T'(si);
  assign o = (si == D) ? '0 : '1;
endmodule
module top #(parameter int SW = 3) (output logic [SW-1:0] c, output logic [SW-1:0] d);
  typedef enum logic [SW-1:0] {E0, E1 = 3'd5} e_t;
  e_t p, q;
  sub #(.T(e_t), .W(SW)) v (.si(p), .so(q), .o(d));
  assign c = q;
endmodule
