// v62e — WHERE the module-local enum constant is READ.  Every carrier that
// could reach (or bypass) the deferred `pendingEnumRefs` queue, in a module
// with THREE specializations.  Question: does the site-keyed fallback bind a
// reference GOLDEN LEAVES BARE anywhere?
module be62 #(parameter int W = 4) (
  input  logic clk,
  input  logic [W-1:0] din,
  output logic [W-1:0] dout,
  output logic [7:0] st
);
  typedef enum logic [1:0] { BA, BB, BC } b_e;
  typedef struct packed { b_e op; logic [1:0] sz; } b_t;
  b_t bv;
  logic p0, p1, p2, p3, p4, p5, p6, p7;
  localparam b_e LP = BB;                       // localparam initializer
  parameter  b_e PP = BC;                       // parameter initializer

  initial p0 = (bv.op == BA);                   // initial block
  always_ff @(posedge clk) p1 <= (bv.op == BB); // always_ff
  always_comb begin
    case (bv.op)                                // CASE LABEL positions
      BA: p2 = 1'b0;
      BB: p2 = 1'b1;
      default: p2 = 1'b0;
    endcase
  end
  function automatic logic fb(input b_e q); return q == BC; endfunction
  task automatic tb(input b_e q, output logic r); r = (q == BA); endtask
  always_comb p3 = fb(bv.op);
  always_comb tb(bv.op, p4);
  assign p5 = (LP == PP);
  assign p6 = (bv.op inside {BA, BC});          // inside set
  always_comb p7 = (b_e'(din[1:0]) == BB);      // cast
  assign st = {p7,p6,p5,p4,p3,p2,p1,p0};
  assign dout = { {(W-2){1'b0}}, bv.sz };
endmodule

module top62e (input logic clk, output logic [15:0] o);
  logic [3:0] d4; logic [7:0] d8, s1, s2, s3; logic [15:0] d16;
  be62 #(.W(4))  u_a (.clk(clk), .din(4'h0),  .dout(d4),  .st(s1));
  be62 #(.W(8))  u_b (.clk(clk), .din(8'h0),  .dout(d8),  .st(s2));
  be62 #(.W(16)) u_c (.clk(clk), .din(16'h0), .dout(d16), .st(s3));
  assign o = d16 ^ {8'b0,d8} ^ {12'b0,d4} ^ {s1,s2} ^ {8'b0,s3};
endmodule
