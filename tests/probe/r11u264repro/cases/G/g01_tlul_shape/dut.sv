// § selRootIpsOpFoldChainName264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
  typedef struct packed { logic d_valid; logic [AIW-1:0] d_source; } d2h_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] tl_h_i, input tp::d2h_t drsp, output logic [M-1:0] rv, output logic [7:0] sh [M], output logic [1:0] un [M]);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  for (genvar i = 0; i < M; i++) begin : gen_host_fifo
    logic [STIDW-1:0] reqid_sub;
    assign reqid_sub = i;
    assign sh[i] = { tl_h_i[i].a_source[0+:(IDW-STIDW)], reqid_sub };
    assign un[i] = tl_h_i[i].a_source[IDW-1 -: STIDW];
  end
  for (genvar i = 0; i < M; i++) begin : gen_idrouting
    assign rv[i] = drsp.d_valid & (drsp.d_source[0+:STIDW] == i);
  end
endmodule
module top(input tp::h2d_t [3:0] h, input tp::d2h_t d, output logic [3:0] rv, output logic [7:0] sh [4], output logic [1:0] un [4]);
  sock #(.M(4)) u(.tl_h_i(h), .drsp(d), .rv(rv), .sh(sh), .un(un));
endmodule
