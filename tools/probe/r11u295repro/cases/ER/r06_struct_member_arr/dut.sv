// § rawEndLineModel295
module dut (output logic o);
  typedef struct { logic \m.a [1:0]; logic b; } s_t;
  s_t s;
  assign s.b = 1'b1;
  assign o = s.b;
endmodule
