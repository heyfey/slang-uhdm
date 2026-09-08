// r10vearl121 PROBE: shapes that might make Surelog's writer flatten a
// GEN-LOCAL whole-name packed-struct target in the DEFAULT view.
package wp121;
  typedef enum logic [2:0] { EA = 3'h0, EB = 3'h4 } e_t;
  typedef struct packed {
    logic       a;
    e_t         op;
    logic [7:0] d;
  } t_t;
endpackage

module vprobe121 (
  input  logic [7:0] din,
  output logic [11:0] y1, y2, y3, y4, y5, y6, y7, y8, y9, y10
);
  // p1 -- NET DECL ASSIGN inside a generate block (decl and assign in one)
  for (genvar i = 0; i < 1; i++) begin : p1
    wp121::t_t c = '{a: 1'b1, op: wp121::EA, d: din};
  end
  assign y1 = p1[0].c;

  // p2 -- explicit `wire` keyword
  for (genvar i = 0; i < 1; i++) begin : p2
    wire wp121::t_t c;
    assign c = '{a: 1'b0, op: wp121::EB, d: din};
  end
  assign y2 = p2[0].c;

  // p3 -- UNNAMED generate block
  if (1) begin
    wp121::t_t c;
    assign c = '{a: 1'b1, op: wp121::EA, d: 8'd3};
  end
  assign y3 = 12'd0;

  // p4 -- explicit generate/endgenerate region
  generate
    for (genvar i = 0; i < 1; i++) begin : p4
      wp121::t_t c;
      assign c = '{a: 1'b0, op: wp121::EB, d: 8'd4};
    end
  endgenerate
  assign y4 = p4[0].c;

  // p5 -- member values read ANOTHER generate block's gen-local struct
  for (genvar i = 0; i < 1; i++) begin : p5
    wp121::t_t c;
    assign c = '{a: p2[0].c.a, op: p2[0].c.op, d: p2[0].c.d};
  end
  assign y5 = p5[0].c;

  // p6 -- generate `else` branch
  if (0) begin : p6t
    wp121::t_t c;
    assign c = '{a: 1'b0, op: wp121::EA, d: 8'd0};
  end else begin : p6
    wp121::t_t c;
    assign c = '{a: 1'b1, op: wp121::EB, d: 8'd6};
  end
  assign y6 = p6.c;

  // p7 -- drive strength on the continuous assign
  for (genvar i = 0; i < 1; i++) begin : p7
    wp121::t_t c;
    assign (strong1, strong0) c = '{a: 1'b1, op: wp121::EA, d: 8'd7};
  end
  assign y7 = p7[0].c;

  // p8 -- case generate
  case (1)
    1: begin : p8
      wp121::t_t c;
      assign c = '{a: 1'b0, op: wp121::EB, d: 8'd8};
    end
    default: begin : p8d
      wp121::t_t c;
      assign c = '{a: 1'b1, op: wp121::EA, d: 8'd0};
    end
  endcase
  assign y8 = p8.c;

  // p9 -- the pattern's members are ALL constants (fully foldable)
  for (genvar i = 0; i < 1; i++) begin : p9
    wp121::t_t c;
    assign c = '{a: 1'b1, op: wp121::EA, d: 8'd9};
  end
  assign y9 = p9[0].c;

  // p10 -- target declared in the generate block, read in the SAME block
  for (genvar i = 0; i < 1; i++) begin : p10
    wp121::t_t c;
    wp121::t_t e;
    assign c = '{a: 1'b0, op: wp121::EB, d: 8'd10};
    assign e = c;
  end
  assign y10 = p10[0].e;
endmodule

// an INTERFACE with the same construct
interface vif121 (input logic [7:0] din);
  for (genvar i = 0; i < 1; i++) begin : q1
    wp121::t_t c;
    assign c = '{a: 1'b1, op: wp121::EA, d: din};
  end
endinterface

module vprobetop121 (input logic [7:0] din, output logic [11:0] z);
  vif121 u_if (.din(din));
  assign z = u_if.q1[0].c;
endmodule
