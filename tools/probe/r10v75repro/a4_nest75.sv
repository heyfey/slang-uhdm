// r10v75 arm a4 -- HOME NESTING: gen-for inside gen-if, gen-if inside gen-for,
// three levels, a case-generate, and an OVERRIDDEN instance parameter D whose
// actual is a multiplication / subtraction / shift / $clog2 / cast, with the
// process positions swept: replication count, indexed part-select width, range
// bound, case item, ternary arm, concat member, call argument.
package a4p;
  parameter int NB = 4;
  parameter int NW = 8;
endpackage

module a4m #(parameter int D = 2, parameter int E = 1)
            (input logic clk, output logic [63:0] o);
  import a4p::*;
  logic [63:0] r0, r1, r2, r3, r4, r5, r6, r7;
  logic [63:0] v;
  if (E > 0) begin : gen_if
    for (genvar g = 0; g < 2; g++) begin : gen_for
      always_comb r0 = {NB{1'b1}};             // A4_P1 for-in-if
      always_comb r1 = v[g*NB +: NB];          // A4_P2 ips width
      always_comb r2 = v[NB-1:0];              // A4_P3 part-select bound
      always_comb r3 = (clk ? NB : NW);        // A4_P4 ternary arms
      always_comb begin                        // A4_P5 case item
        case (v[3:0])
          NB[3:0]: r4 = 1;
          default: r4 = 0;
        endcase
      end
      always_comb r5 = {NB[7:0], NW[7:0]};     // A4_P6 concat members
      always_comb r6 = $clog2(NB) + NB;        // A4_P7 sysfunc arg + operand
      if (g == 0) begin : gen_deep
        always_comb r7 = {NB{1'b1}} & 64'h7;   // A4_P8 three levels deep
      end
    end
  end
  assign o = r0 ^ r1 ^ r2 ^ r3 ^ r4 ^ r5 ^ r6 ^ r7;
endmodule

module a4top (input logic clk, output logic [63:0] o1, o2, o3);
  import a4p::*;
  localparam int LM = 3;
  a4m #(.D(NB * 2), .E(1))        u_m1 (.clk(clk), .o(o1)); // mult actual
  a4m #(.D(NB - 1), .E(1))        u_m2 (.clk(clk), .o(o2)); // sub actual
  a4m #(.D($clog2(NW)), .E(LM))   u_m3 (.clk(clk), .o(o3)); // clog2 actual
endmodule
