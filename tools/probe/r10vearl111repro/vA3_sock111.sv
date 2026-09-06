// v111 adversarial arm A3 -- THE INSTANCE-COUNT axis of the HEAD's own shape.
// tlul_socket_m1 with ONE instance and with THREE, the localparam int unsigned
// derived from the instance's own overridable parameter, read as the width of
// an indexed part-select closing a dotted hier_path on an unpacked array, one
// generate level deep.  If the stamp is instance-scoped in golden and shared
// in ours (or the reverse), the multiplicities move here.
package pk3v111;
  typedef struct packed { logic [15:0] src; logic v; } t_h;
endpackage

module sock3v111 #(parameter int M = 4)
                  (input pk3v111::t_h h_i [4], output logic [63:0] o);
  localparam int unsigned STIDW = (M == 1) ? 1 : $clog2(M);
  localparam int unsigned IDW   = 8;
  logic [63:0] r;
  for (genvar i = 0; i < 2; i++) begin : gen_host
    assign r[(i*4)+1 -: 2] = {1'b0, h_i[i].src[IDW-1 -: STIDW]};
    assign r[(i*4)+3 -: 2] = {1'b0, h_i[i].src[0 +: STIDW]};
  end
  assign o = r;
endmodule

module one3v111 (input pk3v111::t_h a [4], output logic [63:0] o);
  sock3v111 #(.M(2)) u_only (.h_i(a), .o(o));
endmodule

module vA3_sock111;
  pk3v111::t_h hh [4];
  logic [63:0] o0, o1, o2, o3;
  one3v111      u_one (.a(hh), .o(o0));
  sock3v111 #(.M(2)) u_a (.h_i(hh), .o(o1));
  sock3v111 #(.M(4)) u_b (.h_i(hh), .o(o2));
  sock3v111 #(.M(8)) u_c (.h_i(hh), .o(o3));
endmodule
