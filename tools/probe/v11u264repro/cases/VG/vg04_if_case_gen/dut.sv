// § plainMemberIpsOwner264
package tp;
  localparam int AIW = 8;
  typedef struct packed { logic v; logic [AIW-1:0] a_source; } h2d_t;
endpackage
module sock #(parameter int unsigned M = 4) (input tp::h2d_t [M-1:0] h, input tp::h2d_t d, output logic [7:0] x [M], output logic [M-1:0] rv);
  localparam int unsigned IDW = tp::AIW;
  localparam int unsigned STIDW = $clog2(M);
  if (M > 2) begin : ig
    assign rv[0] = d.a_source[0+:STIDW] == 2'd1;
    assign x[0] = h[0].a_source[0+:(IDW-STIDW)];
  end
  case (M)
    4: begin : cg
      assign rv[1] = d.a_source[1+:STIDW] == 2'd2;
      assign x[1] = h[1].a_source[0+:(IDW-STIDW)];
    end
    default: ;
  endcase
  assign rv[3:2] = '0;
  assign x[2] = '0;
  assign x[3] = '0;
endmodule
module top(input tp::h2d_t [3:0] h, input tp::h2d_t d, output logic [7:0] x [4], output logic [3:0] rv);
  sock #(.M(4)) u(.h(h), .d(d), .x(x), .rv(rv));
endmodule
