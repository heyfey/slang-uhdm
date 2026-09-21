// r11v81 adversarial arm v7 — `default:` setters and a replication over a
// package hop.
package v7p;
  localparam PH = 16'h5;
  localparam PD = 16'd5;
  typedef struct packed { logic [23:0] a; logic [23:0] b; } t7;
  localparam t7 D1 = '{default: PH};
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b;
  } t7b;
  localparam t7b D2 = '{bail: 8'hxA, a: PD, default: PH};
endpackage
module v7_defrep81 #(parameter v7p::t7b CD = v7p::D2) (output logic [23:0] o);
  localparam v7p::t7 L1 = v7p::D1;
  assign o = CD.a ^ CD.b ^ L1.a ^ L1.b;
endmodule
