// r10earl111 arm g1 -- THE HEAD, reproduced.  Earlgrey_0_1/testflags,
// tlul_socket_m1.sv:73/97/105/235/237: a module-BODY `localparam int unsigned`
// read as the WIDTH half of an indexed part-select closing a DOTTED hier_path,
// one generate level deep, on an unpacked ARRAY of structs.
// Golden stamps the folded width constant with the localparam's own
// int_typespec; the pristine emitter leaves it bare.
package hp111;
  typedef struct packed { logic [15:0] src; logic v; } t_h;
endpackage

module socket111 #(parameter int M = 4)
                  (input hp111::t_h h_i [4], output logic [63:0] o);
  localparam int unsigned IDW   = 8;   // c1 the head's own declaration
  localparam int unsigned STIDW = 2;   // c2
  logic [63:0] r;
  for (genvar i = 0; i < 4; i++) begin : gen_host
    // c1 the `-:` half -- the exact head cell (tlul_socket_m1.sv:105)
    assign r[(i*4)+1 -: 2] = h_i[i].src[IDW-1 -: STIDW];
    // c2 the `+:` half at the same site (tlul_socket_m1.sv:235/237)
    assign r[(i*4)+3 -: 2] = h_i[i].src[0 +: STIDW];
  end
  assign o = r;
endmodule

module g1_head111;
  hp111::t_h hh [4];
  logic [63:0] oo;
  socket111 #(.M(4)) u_s (.h_i(hh), .o(oo));
endmodule
