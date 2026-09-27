// § tpEnumCopyAtTypedef184: an enum typedef declared in a generate block and passed to an instance there
module sub #(parameter type T = logic) (input T si, output T so);
  assign so = si;
endmodule
module top #(parameter bit P = 1) (input logic [1:0] a, output logic [1:0] b);
  if (P) begin : g
    typedef enum logic [1:0] {G0, G1, G2} g_e;
    g_e x, y;
    assign x = g_e'(a);
    sub #(.T(g_e)) u (.si(x), .so(y));
    assign b = y;
  end
endmodule
