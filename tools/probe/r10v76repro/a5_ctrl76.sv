// r10v76 arm a5 -- (i) the FOREVER / EVENT-CONTROL / DELAY positions the
// implementer's README asserts fold but never built, and (ii) the DECIMAL
// based-literal decompile the encoder gets wrong.
package v76p5;
  parameter int      NB   = 4;
  parameter bit [7:0] D8  = 8'd12;      // UNSIGNED decimal base
  parameter byte      DS8 = 8'sd12;     // SIGNED decimal base
  parameter bit [7:0] H8  = 8'hA5;      // hex   (the g2 control)
  parameter bit [7:0] B8  = 8'b1010_0001; // binary
  parameter bit [7:0] O8  = 8'o17;      // octal
  parameter longint   D64 = 64'd4294967296;
endpackage

module v76ctrl #(parameter int P = 2) (input logic clk, output logic [31:0] o);
  import v76p5::*;
  logic [31:0] e1, e2, e3, e4, e5, e6;

  if (P > 0) begin : gc_a
    initial begin
      e1 = 0;
      forever begin
        e1 = e1 + NB;                    // FOREVER body, PLAIN statement
        @(posedge clk);
      end
    end
  end

  if (P > 0) begin : gc_b
    initial begin
      e2 = 0;
      forever @(posedge clk) e2 = e2 + NB;  // FOREVER + EVENT CONTROL
    end
  end

  if (P > 0) begin : gc_c
    always @(posedge clk) e3 <= e3 + NB;    // EVENT CONTROL, no forever
  end

  if (P > 0) begin : gc_d
    initial begin
      e4 = 0;
      #5 e4 = e4 + NB;                      // DELAY control
      wait (e4 > NB) e4 = e4 + 1;           // WAIT condition
    end
  end

  if (P > 0) begin : gc_e
    always_comb begin
      e5 = '0;
      e5 = e5 + NB;                         // the PLAIN control (golden folds)
    end
  end

  // the DECIMAL/HEX/BIN/OCT based-literal decompile grid, in the FENCED
  // position (a for CONDITION in a gen-scope process)
  if (P > 0) begin : gc_f
    always_comb begin
      e6 = '0;
      for (int i = 0; i < D8;  i++) e6 = e6 + 1;
      for (int i = 0; i < DS8; i++) e6 = e6 + 1;
      for (int i = 0; i < H8;  i++) e6 = e6 + 1;
      for (int i = 0; i < B8;  i++) e6 = e6 + 1;
      for (int i = 0; i < O8;  i++) e6 = e6 + 1;
      for (longint i = 0; i < D64; i = i + D64) e6 = e6 + 1;
    end
  end

  assign o = e1 ^ e2 ^ e3 ^ e4 ^ e5 ^ e6;
endmodule

module v76ctrltop (input logic clk, output logic [31:0] o1);
  v76ctrl #(2) u_c (.clk(clk), .o(o1));
endmodule
