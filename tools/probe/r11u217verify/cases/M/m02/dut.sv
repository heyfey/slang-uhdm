// § memLeftReadsPatUnlocated210 — r11u217 m02: one builder called TWICE with two pattern parameters (one in the same package as the builder, one module-local), the computed member reading the formal member in an arithmetic expression
package cfgp;
  typedef struct packed { bit EN; logic [3:0] K; } user_t;
  typedef struct packed { int unsigned A; int unsigned B; } full_t;
  localparam user_t PK = '{ EN: 1'b0, K: 4'd3 };
  function automatic full_t build(user_t U);
    full_t f;
    f.A = 8;
    f.B = f.A * U.K + (U.EN ? 1 : 2);
    return f;
  endfunction
endpackage
module dut(output int o, output int p);
  localparam cfgp::user_t LOC = '{ EN: 1'b1, K: 4'd5 };
  localparam cfgp::full_t P1 = cfgp::build(cfgp::PK);
  localparam cfgp::full_t P2 = cfgp::build(LOC);
  assign o = P1.B;
  assign p = P2.B;
endmodule
