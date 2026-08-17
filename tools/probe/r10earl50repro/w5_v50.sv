// r10earl50 VERIFIER arm w5 — the EDGES of the three verifier fixes:
// nested (multidimensional) instance arrays, arrays inside for-generates,
// case-generate DEFAULT items and multi-label items, and a parameter
// initializer inside an UNTAKEN generate branch.
module w5_sub #(parameter logic [31:0] S = 'h0)
              (input logic p, output logic y);
  assign y = (^S) & p;
endmodule

module w5_v50 #(
  parameter int           W  = 32,
  parameter logic [W-1:0] U1 = 'h1,  // select in a 2-D instance ARRAY override
  parameter logic [W-1:0] U2 = 'h1,  // select in an instance ARRAY inside a for-generate
  parameter logic [W-1:0] U3 = 'h1,  // select in the SECOND label of a multi-label case item
  parameter logic [W-1:0] U4 = 'h1,  // select in a param initializer in an UNTAKEN gen branch
  parameter logic [W-1:0] U5 = 'h1,  // select in a param initializer in a FOR-generate
  parameter logic [W-1:0] U6 = 'h1,  // select in a case-generate item under an UNTAKEN branch
  parameter logic [W-1:0] U7 = 'h1,  // select in an instance ARRAY port conn in an UNTAKEN branch
  parameter logic [W-1:0] U8 = 'h1   // select in a MODULE-LEVEL param initializer (control, h1.H5)
) (
  input  logic         c,
  input  logic [W-1:0] n,
  output logic [3:0]   oa1,
  output logic [1:0]   oa2
);
  // U8 — the module-level control this pass declares it does not touch
  localparam logic [W-1:0] U8D = {24'b0, U8[7:0]};
  wire [W-1:0] t8; assign t8 = U8D;

  // U1 — a 2-D instance array
  w5_sub #(.S({24'b0, U1[7:0]})) u_u1 [1:0][1:0] (.p(c), .y(oa1));

  // U2 — an instance array inside a for-generate
  for (genvar k = 0; k < 1; k++) begin : gen_u2
    w5_sub #(.S({24'b0, U2[7:0]})) u [1:0] (.p(c), .y(oa2));
  end

  // U3 — a multi-label case-generate item; the select is the SECOND label
  case (W)
    31, U3[4:0]: begin : gen_u3a  wire [W-1:0] t3; assign t3 = n; end
    default:     begin : gen_u3b  wire [W-1:0] t4; assign t4 = n; end
  endcase

  // U4 / U6 / U7 — everything below sits in an UNTAKEN generate branch
  if (W > 99) begin : gen_dead
    localparam logic [W-1:0] U4D = {24'b0, U4[7:0]};
    wire [W-1:0] t44; assign t44 = U4D;
    case (W)
      U6[4:0]: begin : gen_u6a  wire [W-1:0] t6; assign t6 = n; end
      default: begin : gen_u6b  wire [W-1:0] t7; assign t7 = n; end
    endcase
    wire [1:0] oy7;
    w5_sub #(.S(32'h0)) u_u7 [1:0] (.p(U7[0]), .y(oy7));
  end

  // U5 — a parameter initializer inside a for-generate body
  for (genvar k = 0; k < 1; k++) begin : gen_u5
    localparam logic [W-1:0] U5D = {24'b0, U5[7:0]};
    wire [W-1:0] t5; assign t5 = U5D;
  end
endmodule
