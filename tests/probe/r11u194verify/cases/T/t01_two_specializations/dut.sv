// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: two instances of one child, overridden by two module-local enums of different widths; one child body writes a whole T variable by continuous assignment
module sub #(parameter type T = logic, parameter bit CA = 0) (input T si, output logic [7:0] so);
  T r;
  if (CA) begin : g
    assign r = si;
  end else begin : h
    always_comb r = si;
  end
  assign so = 8'(r);
endmodule
module top (output logic [7:0] a, output logic [7:0] b);
  typedef enum logic [1:0] {N0, N1, N2} narrow_e;
  typedef enum logic [5:0] {W0 = 6'd3, W1 = 6'd40} wide_e;
  narrow_e pn;
  wide_e pw;
  sub #(.T(narrow_e), .CA(1)) u0 (.si(pn), .so(a));
  sub #(.T(wide_e), .CA(0)) u1 (.si(pw), .so(b));
endmodule
