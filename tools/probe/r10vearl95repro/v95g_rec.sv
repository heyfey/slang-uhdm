// r10v95 -- adversarial arm G: RECURSIVE generate instantiation (a module that
// instantiates itself inside its own generate scope), a 2-level INSTANCE
// CROSSING, and a $unit-scope parameter.  Every one of these puts a frame on
// the emitted gen stack that belongs to a DIFFERENT InstanceBody.
parameter int UNITP = 3;

module rec95 #(parameter int N = 3) (input logic [31:0] din, output logic [7:0] o);
  localparam int RP = 2;
  localparam logic [63:0] RTBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};
  logic [7:0] sub;
  if (N > 0) begin : g_rec
    assign o = RTBL[RP-1][7:0] ^ sub;          // distance 1 -> golden folds
    rec95 #(.N(N-1)) u_next (.din(din), .o(sub));
    if (N > 1) begin : g_in
      // distance 2 from g_in -> golden keeps
      wire [7:0] unused = RTBL[RP-1][7:0];
    end
  end
  else begin : g_leaf
    assign o = RTBL[UNITP-1][7:0];             // $unit parameter, folds always
    assign sub = 8'd0;
  end
endmodule

// two-level instance crossing: gen -> inst -> gen -> inst -> gen
module inner95 #(parameter int W = 8) (input logic [31:0] din, output logic [7:0] o);
  localparam int IP = 2;
  localparam logic [63:0] ITBL [0:7] = '{64'd0,64'd1,64'd2,64'd3,64'd4,64'd5,64'd6,64'd7};
  if (W > 0) begin : i1
    assign o = ITBL[IP-1][7:0] | ITBL[UNITP-1][7:0];
  end
endmodule

module midg95 #(parameter int W = 8) (input logic [31:0] din, output logic [7:0] o);
  if (W > 0) begin : m1
    if (W > 0) begin : m2
      inner95 #(.W(W)) u_in (.din(din), .o(o));
    end
  end
endmodule

module v95g_rec (input logic [31:0] din, output logic [7:0] o1, output logic [7:0] o2);
  rec95  #(.N(3)) u_rec (.din(din), .o(o1));
  midg95 #(.W(8)) u_mid (.din(din), .o(o2));
endmodule
