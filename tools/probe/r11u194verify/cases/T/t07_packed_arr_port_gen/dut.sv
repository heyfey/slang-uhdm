// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a packed array of T declared in the body written whole by a continuous assignment in a generate block, and an unpacked array of T written by elements
module sub #(parameter type T = logic) (input T si, output logic [3:0] so);
  T [1:0] pk;
  T up [2];
  if (1) begin : g
    assign pk = {si, si};
  end
  assign up[0] = si;
  assign up[1] = si;
  assign so = pk;
endmodule
module top (output logic [3:0] c);
  typedef enum logic [1:0] {R0, R1, R2} r_e;
  r_e p;
  sub #(.T(r_e)) v (.si(p), .so(c));
endmodule
