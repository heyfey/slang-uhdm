// § memLeftReadsPatUnlocated210 — r11u217 m03: the builder result used as a PARAMETER OVERRIDE of a child and in a generate condition, the formal member read through a nested struct member `U.S.EN`
package cfgp;
  typedef struct packed { bit EN; } sub_t;
  typedef struct packed { sub_t S; logic [3:0] K; } user_t;
  typedef struct packed { int unsigned W; int unsigned N; } full_t;
endpackage
package valp;
  localparam cfgp::user_t ucfg = '{ S: '{ EN: 1'b1 }, K: 4'd2 };
  function automatic cfgp::full_t build(cfgp::user_t U);
    cfgp::full_t f;
    f.W = 16;
    f.N = U.S.EN == 1'b1 ? f.W / 4 : 1;
    return f;
  endfunction
endpackage
module ch #(parameter cfgp::full_t C = '0) (output int o);
  assign o = C.N;
endmodule
module dut(output int o, output logic q);
  localparam cfgp::full_t P = valp::build(valp::ucfg);
  ch #(.C(P)) u (.o(o));
  if (P.N > 2) begin : g
    assign q = 1'b1;
  end else begin : h
    assign q = 1'b0;
  end
endmodule
