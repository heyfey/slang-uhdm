// r10v95 -- adversarial arm B: the HOME axis.  The same depth-1 / depth-2
// gen-scope select in a plain module, at the bottom of a 3-DEEP instance
// chain, inside an INTERFACE, and inside an INSTANCE ARRAY element.
interface ifc95 #(parameter int IW = 8) (input logic [31:0] din);
  localparam int IP = 3;
  localparam logic [63:0] ITBL [0:3] = '{64'd1, 64'd2, 64'd3, 64'd4};
  logic [7:0] i1, i2;
  if (IW > 0) begin : if_d1
    assign i1 = ITBL[IP-1][7:0];
    if (IW > 0) begin : if_d2
      assign i2 = ITBL[IP-1][7:0];
    end
  end
endinterface

module leaf95 #(parameter int W = 8) (input logic [31:0] din,
                                      output logic [7:0] o1, output logic [7:0] o2);
  localparam int LP = 3;
  localparam logic [63:0] TBL [0:3] = '{64'd1, 64'd2, 64'd3, 64'd4};
  if (W > 0) begin : l_d1
    assign o1 = TBL[LP-1][7:0];
    if (W > 0) begin : l_d2
      assign o2 = TBL[LP-1][7:0];
    end
  end
endmodule

module mid95 #(parameter int W = 8) (input logic [31:0] din,
                                     output logic [7:0] o1, output logic [7:0] o2);
  leaf95 #(.W(W)) u_leaf (.din(din), .o1(o1), .o2(o2));
endmodule

module chain95 #(parameter int W = 8) (input logic [31:0] din,
                                       output logic [7:0] o1, output logic [7:0] o2);
  mid95 #(.W(W)) u_mid (.din(din), .o1(o1), .o2(o2));
endmodule

// a leaf whose OWN top-level gen block is emitted while the PARENT's gen
// frames are still on the emitted stack -- the instance-boundary case
module hostgen95 #(parameter int W = 8) (input logic [31:0] din,
                                         output logic [7:0] o1, output logic [7:0] o2);
  if (W > 0) begin : h_outer
    leaf95 #(.W(W)) u_in (.din(din), .o1(o1), .o2(o2));
  end
endmodule

module arr95 #(parameter int W = 8) (input logic [31:0] din, output logic [7:0] o1 [0:1], output logic [7:0] o2 [0:1]);
  leaf95 #(.W(W)) u_arr [0:1] (.din(din), .o1(o1), .o2(o2));
endmodule

module v95b_homes (input logic [31:0] din,
  output logic [7:0] p1, p2, q1, q2, r1, r2,
  output logic [7:0] s1 [0:1], output logic [7:0] s2 [0:1],
  output logic [7:0] t1, t2);
  logic [7:0] iu1, iu2;
  chain95   #(.W(8))  u_chain (.din(din), .o1(p1), .o2(p2));
  chain95   #(.W(16)) u_chain2(.din(din), .o1(q1), .o2(q2));
  hostgen95 #(.W(8))  u_host  (.din(din), .o1(r1), .o2(r2));
  arr95     #(.W(8))  u_arr   (.din(din), .o1(s1), .o2(s2));
  ifc95     #(.IW(8)) u_ifc   (.din(din));
  assign t1 = u_ifc.i1;
  assign t2 = u_ifc.i2;
endmodule
