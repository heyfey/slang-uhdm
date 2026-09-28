// § tpEnumCopyAtTypedef184 § tpEnumCaBindsInstVar184v: a packed struct of T in the child written whole by a continuous assignment (a struct is neither T nor a packed array of T)
module sub #(parameter type T = logic) (input T si, output logic [4:0] so);
  typedef struct packed { T f; logic [2:0] g; } s_t;
  s_t r;
  assign r = '{f: si, g: 3'd1};
  assign so = r;
endmodule
module top (output logic [4:0] c);
  typedef enum logic [1:0] {V0, V1} v_e;
  v_e p;
  sub #(.T(v_e)) v (.si(p), .so(c));
endmodule
