// § ndaSysCallNetTs212 § memLeftReadsPatUnlocated210 — r11u217 x03: a net declaration initialized by a signing cast of a struct-builder result member, the builder's actual a pattern parameter of another package
package cfgp;
  typedef struct packed { bit EN; logic [3:0] K; } user_t;
  typedef struct packed { logic [7:0] W; logic [7:0] N; } full_t;
endpackage
package valp;
  localparam cfgp::user_t ucfg = '{ EN: 1'b1, K: 4'd3 };
  function automatic cfgp::full_t build(cfgp::user_t U);
    cfgp::full_t f;
    f.W = 8'd16;
    f.N = U.EN == 1'b1 ? f.W / 8'd4 : 8'd1;
    return f;
  endfunction
endpackage
module dut(output logic [7:0] o);
  localparam cfgp::full_t P = valp::build(valp::ucfg);
  wire [7:0] n = $unsigned(P.N);
  assign o = n;
endmodule
