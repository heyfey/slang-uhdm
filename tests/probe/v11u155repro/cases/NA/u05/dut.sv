// § nonAnsiArrayNetAtHeader155
typedef struct packed { logic [1:0] x; } st;
module dut(a, o);
  input st a [2];
  output st o;
  assign o = a[1];
endmodule
